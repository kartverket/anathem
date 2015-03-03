#!/usr/bin/env python26
""" 
anathem - a simple template processing script around mako and yaml. 
Use YAML configuration files to combine mako templates.
"""

from mako.template import *
from mako.lookup import TemplateLookup
import yaml
import sys
import re
import closure
from subprocess import call

# matches mako parameters in a template: ${...}, but not containing brackets
re_param = re.compile('\$\{([^\(\{]*?)\}')

# parameter: a yaml configuration filename in the themes/ folder, a destination directory
nil, tema, destdir = sys.argv[0:3]
options=[]
if len(sys.argv) > 3:
  options = sys.argv[3:]

compress   = not "no-compression" in options
defaults   = yaml.load(open("default.yaml", "r"))
lookup     = TemplateLookup(directories=['./templates/'])

templates  = open("themes/%s.yaml" % tema, "r").read().split("---")
config     = [yaml.load(doc) for doc in templates]

def recurse_render(data):
  """
  render a template as indicated by the given configuration.
  data: a dictionary containing at least a "template" key, and
  one key for every parameter the template includes
  """

  if "include" in data:
    # load another configuration file indicated by the include key
    include_name = data["include"]
    include = yaml.load(open("themes/%s.yaml" % include_name, "r"))
    return recurse_render(include)

  elif "template" in data:
    # load template indicated by the template key
    template_name = data["template"]
    try:
      template = Template(filename=("templates/%s.mako" % template_name), lookup=lookup)
    except:
      template = Template(filename=("templates/%s.html" % template_name), lookup=lookup)
    # for every other key in the configuration:
    # if it is a dict, render a subtemplate
    # if it is a list, render an array of subtemplates
    for key,value in data.items():
      try:
        if type(value)==type(dict()):
          data[key] = recurse_render(value)
        if type(value)==type(list()):
          data[key] = "\n".join([recurse_render(x) for x in value])
      except IOError, er:
        print "Template specified in configuration %s was not found:" % template_name
        print er
        sys.exit(1)
    # then render the main template
    # or catch any exceptions, and be a bit smart helping the user to find the mistake
    allkeys = defaults.copy()
    allkeys.update(data)
    allkeys['vars'] = defaults
    try:
      return template.render(**allkeys)
    except NameError, er:
      print "\nMissing parameter while parsing template '%s'." % template_name

      try:
        code   = open("templates/%s.html" % template_name, "r").read()
        params = re_param.findall(code)
        print "The template supports *and* requires the following parameters:"
        print "Provide it with an empty string if it is not to be included.\n"
        for param in params:
          print "%s %s" % (param in allkeys and "OK:     " or "MISSING:",param)
        print ""
      except:
        print "DEBUG: could not parse template code to identify required parameters."

      #print exceptions.text_error_template().render()
      sys.exit(1)
    except TypeError, er:
      print "DEBUG: Template method was not callable."
      print exceptions.text_error_template().render()
      sys.exit(1)

def output_file(name, payload):
  dots = name.split(".")
  file = ".".join(dots[:-1])
  ext  = dots[-1]
  if   ext == "coffee" or ext == "cs":
    fd = open("tmp/tmp.coffee", "w")
    fd.write(payload.encode('utf-8'))
    fd.close()
    if call(["coffee", "-bo", "tmp/", "-c", "tmp/tmp.coffee"]):
      print "Error compiling coffeescript."
      sys.exit(1)
    ext = "js"
    #if call(["java", "-jar", closure.get_jar_filename(), "--js", "tmp/tmp.js", "--js_output_file", "tmp/"+file+".js"])
    #  print "Error compressing javascript."
    #  sys.exit(1)
    #os.unlink("tmp/tmp.js")
    os.rename("tmp/tmp.js", "tmp/"+file+".js")
    os.unlink("tmp/tmp.coffee")
  elif ext == "ls":
    fd = open("tmp/tmp.ls", "w")
    fd.write(payload.encode('utf-8'))
    fd.close()
    if call(["lsc", "-bo", "tmp/", "-c", "tmp/tmp.ls" ]):
      print "Error compiling livescript."
      sys.exit(1)
    ext = "js"
    #if call(["java", "-jar", closure.get_jar_filename(), "--js", "tmp/tmp.js", "--js_output_file", "tmp/"+file+".js"])
    #  print "Error compressing livescript."
    #  sys.exit(1)
    #os.unlink("tmp/tmp.js")
    os.rename("tmp/tmp.js", "tmp/"+file+".js")
    os.unlink("tmp/tmp.ls")
  elif ext == "js":
    if compress:
      fd = open("tmp/tmp.js", "w")
      fd.write(payload.encode('utf-8'))
      fd.close()
      if call(["java", "-jar", closure.get_jar_filename(), "--js", "tmp/tmp.js", "--js_output_file", "tmp/"+name]):
        print "Error compressing javascript."
        sys.exit(1)
      os.unlink("tmp/tmp.js")
    else:
      fd = open("tmp/"+name, "w")
      fd.write(payload.encode('utf-8'))
  else:
    fd = open("tmp/"+name, "w")
    fd.write(payload.encode('utf-8'))
    fd.close()
  print "%s/%s.%s" % (destdir, file, ext)
  try:
    os.rename("tmp/%s.%s" % (file, ext), "%s/%s.%s" % (destdir, file, ext)) # move to output directory
  except OSError,er:
    print "Could not find target: %s/%s.%s " % (destdir, file, ext)
    sys.exit(1)

[output_file(c["filename"], recurse_render(c)) for c in config]

