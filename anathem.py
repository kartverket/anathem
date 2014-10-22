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

# single parameter: a yaml configuration filename in the themes/ folder
nil, tema, = sys.argv
config   = yaml.load(open("themes/%s.yaml" % tema, "r"))
defaults = yaml.load(open("default.yaml", "r"))
lookup   = TemplateLookup(directories=['./templates/'])

def recurse_render(data, breadcrumbs):
  """
  render a template as indicated by the given configuration. 
  data: a dictionary containing at least a "template" key, and 
  one key for every parameter the template includes
  """

  if "include" in data:
    # load another configuration file indicated by the include key
    include_name = data["include"]
    include = yaml.load(open("themes/%s.yaml" % include_name, "r"))
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
      return template.render(**allkeys)
    except NameError, er:
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
  
print recurse_render(config, [])


