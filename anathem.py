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
re_param = re.compile('\$\{([^\(]*?)\}')

# single parameter: a yaml configuration filename in the themes/ folder
nil, tema, = sys.argv
config   = yaml.load(open("themes/%s.yaml" % tema, "r"))
defaults = yaml.load(open("default.yaml", "r"))
lookup   = TemplateLookup(directories=['./templates/'])

def recurse_render(data):
  """
  render a template as indicated by the given configuration. 
  data: a dictionary containing at least a "template" key, and 
  one key for every parameter the template includes
  """

  # load template indicated by the template key
  template_name = data["template"]
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
  allkeys['vars']=defaults
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

print recurse_render(config)


