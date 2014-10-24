anathem
=======

A simple template processor to build modular OpenLayers clients, using mako templates.

    ./anathem.py theme

runs the processor on the configuration file "theme.yaml" in the themes subdirectory. The theme determines how to assemble the templates in the templates subdirectory.


# Templates 

Templates follow the mako include syntax. In particular:

    ${param}

includes a parameter from the configuration. 
Templates may also contain programming logic in python syntax - everything within ```${``` and ```}``` and lines preceded with a % are executed by a python interpreter. See http://makotemplates.org for more information, and the templates/ directory for examples.

# Configuration 

There are several ways to provide parameters to each template. 

## Themes 

A theme file is written in YAML syntax. It should contain at least one dictionary type with a "template" key. The most simple theme file is therefore:

    template: name

In addition, the dictionary may contain parameter values to this template. These values may, in themselves, be templates. 
Each parameter may be of one of the following types:

* value (string or number) - this is directly replaced into the template

```
    title : Norgeskart
```

* dictionary - A single subtemplate, marked through curly brackets or 
  indentation. This must again contain at least the "template" parameter

```
    script:
      template: scripts/default 
      parameter: value
```      

* list - A list of subtemplates. These will be processed, concatenated and 
  inserted at the placeholder

```
    layers:  
      - template: layer1
        parameter: value1
      - template: layer2
        parameter: value2
```

## Includes

Any parameter may be replaced with an include statement, which compiles and includes another yaml configuration file:

```
    layers:  
      - include: standard_setup
```



## Default values 

The file ```./defaults``` may contain a dictionary of default values, that are provided to every template.

## Values provided in the template code 

In some cases, a template may want to provide a value directly to another template. Currently, this is done by writing it into a dictionary named ```vars```, which can then be read from the other template. We are looking for a more flexible way to do this.

    template 1:
      <% vars['labelScaleLimit'] = 500000 %>
      <%include file="template2.html" />
      
    template 2:
      minScaleDenominator: ${vars['labelScaleLimit']}
