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

# matches mako parameters in a template: ${...}, but not containing brackets
re_param = re.compile('\$\{([^\(\{]*?)\}')
re_doc   = re.compile('<%doc>(.*?)</%doc>', re.DOTALL ^ re.MULTILINE)

# single parameter: a yaml configuration filename in the themes/ folder
quiet = False # only check if documentation is complete, do not print documentation
if len(sys.argv) == 3:
  nil, tema, quiet, = sys.argv
else:
  nil, tema, = sys.argv

config   = yaml.load(open("themes/%s.yaml" % tema, "r"))
defaults = yaml.load(open("default.yaml", "r"))
lookup   = TemplateLookup(directories=['./templates/'])

mentioned = {}
tree      = {} 

def write_structure(fd, tree, indent):
  for key in sorted(tree.keys()):
    fd.write(" "*indent)
    fd.write("* ")
    if "inc:" in key:
      fd.write("[%s](./includes/%s.md)" % (key.replace("inc:",""), key.replace("inc:","").replace("/","_")))
    else: 
      fd.write("[%s](./templates/%s.md)" % (key, key.replace("/","_")))
    fd.write("\n")
    write_structure(fd, tree[key], indent+2)

def write_docs(mentioned):
  for key in mentioned:
    if "inc:" in key:
      fd = open("doc/includes/"+key.replace("inc:","").replace("/","_")+".md", "w")
    else: 
      fd = open("doc/templates/"+key.replace("/","_")+".md", "w")
    fd.write(mentioned[key])
    fd.close()

def build_template_doc(code):
  lines = ""
  doc = re_doc.search(code)
  data = doc and yaml.load(doc.group(1)) or {}
  if 'description' in data:
    if not quiet:
      try:
        lines += data['description'] + "\n"
      except Exception,ex:
        lines += data + "\n"
    if code:
      params = re_param.findall(code)
      if len(params)>0:
        if 'params' in data:
          if not quiet:
            lines += "Parameters:\n\n"
          for param in params:
            if not quiet:
              lines += "* %s: %s\n" % (param, data['params'][param])
            elif not param in data['params']:
              lines += "parameter %s missing\n" % param
        else:
          lines += "parameter documentation missing\n" 
  else:
    lines += "undocumented\n"
  return lines

def build_include_doc(data):
  lines = ""
  if 'doc' in data:
    if not quiet:
      lines += data['doc']['description']+"\n"
  else:
    lines += "undocumented\n"
  return lines

def register(breadcrumbs):
  level = tree
  for crumb in breadcrumbs:
    if not crumb in level:
      level[crumb] = {}
    level = level[crumb]

def recurse_render(data, breadcrumbs):
  """
  render a template as indicated by the given configuration. 
  data: a dictionary containing at least a "template" key, and 
  one key for every parameter the template includes
  """

  register(breadcrumbs)

  if "include" in data:
    # load another configuration file indicated by the include key
    include_name = data["include"]
    include = yaml.load(open("themes/%s.yaml" % include_name, "r"))
    if not "inc:"+include_name in mentioned:
      mentioned["inc:"+include_name] = "### INCLUDE: %s\n\n%s" % (include_name, build_include_doc(include))
    return recurse_render(include, breadcrumbs + ['inc:'+include_name])

  elif "template" in data:
    # load template indicated by the template key
    template_name = data["template"]

    template = Template(filename=("templates/%s.html" % template_name), lookup=lookup)

    # for every other key in the configuration:
    # if it is a dict, render a subtemplate
    # if it is a list, render an array of subtemplates
    for key,value in data.items():
      try: 
        if type(value)==type(dict()):
          data[key] = recurse_render(value, breadcrumbs + [template_name])
        if type(value)==type(list()):
          data[key] = "\n".join([recurse_render(x, breadcrumbs + [template_name]) for x in value])
      except IOError, er:
        print "Template specified in configuration %s was not found:" % template_name
        print er
        sys.exit(1)
      except TypeError, er:
        print "Error in template structure in %s:" % template_name
        print er
        sys.exit(1)
    # then render the main template
    # or catch any exceptions, and be a bit smart helping the user to find the mistake
    allkeys = defaults.copy()
    allkeys.update(data)
    allkeys['vars']=defaults
    try:
      if not template_name in mentioned:
        register(breadcrumbs+[template_name])
        code   = open("templates/%s.html" % template_name, "r").read()
        mentioned[template_name]="### TEMPLATE: %s\n\n%s" % (template_name, build_template_doc(code))
     
      return template.render(**allkeys)
    except NameError, er:
      print er
      print "\nMissing parameter while parsing template '%s'. <br/>" % template_name
      print "\nPath: %s <br/>" % ("; ".join(breadcrumbs),)
       
      try: 
        code   = open("templates/%s.html" % template_name, "r").read()
        params = re_param.findall(code)
        print "The template supports *and* requires the following parameters: <br/>"
        print "Provide it with an empty string if it is not to be included. <br/><br/>\n"
        for param in params:
          print "%s %s <br/>" % (param in allkeys and "OK:     " or "MISSING:",param)
        print "<br/>"
      except:
        print "DEBUG: could not parse template code to identify required parameters.<br/>"

      #print exceptions.text_error_template().render()
      sys.exit(1)
    except TypeError, er:
      print "DEBUG: Template method was not callable."
      print exceptions.text_error_template().render()
      sys.exit(1)
  
recurse_render(config, [])

fd = open("doc/"+tema+".md", "w")
fd.write("## THEME %s\n\n" % tema)
write_structure(fd,tree,0)
write_docs(mentioned)

