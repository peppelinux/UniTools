XPath Reference
---------------

Resources:
 - http://learn.onion.net/language=en/35426/w3c-xpath

Todo:
 - following-sibling::product -> Da studiare in contesto globale

Xpath command local test: example here.

### Attribute selection
````
<document name="getit Übungsaufgaben" />

/document/@name
````

### Conditional element selection
````
<document xmlns:xlink="http://www.w3.org/1999/xlink">
  <linkList name="A">
    <document xlink:href="15024" />
    <document xlink:href="15028" />
  </linkList>
  <linkList name="B">
    <document xlink:href="15030" />
    <document xlink:href="15032" />
  </linkList>
</document>

/document/linkList[@name = 'A']/document
````

### Merging character strings
````
<person>
  <lastName>Peter</lastName>
  <firstName>Hans</firstName>
</person>

concat(person/lastName, ', ', person/firstName)
````

### Filtering by attribute value
````
<jobs>
  <job priority="critical" name="Müll rausbringen" />
  <job priority="low" name="Möbel säubern" />
  <job priority="low" name="Teppich reinigen" />
  <job priority="medium" name="Fenster putzen" />
  <job priority="high" name="Pflanzen gießen" />
</jobs>

/jobs/job[@priority = 'critical' or @priority = 'high']
````

### Filtering by numeric values and by slice position
````
<persons>
  <person firstName="Hans" lastName="Mustermann" age="28" />
  <person firstName="Herbert" lastName="Möllemann" age="33" />
  <person firstName="Peter" lastName="Meier" age="37" />
  <person firstName="Ulrike" lastName="Albrecht" age="45" />
</persons>

persons/person[@age < 35]
persons/person[position() <= 3]

# with max-lenght of 5 digits
persons/person[string-length(@firstName) <= 5]
````

### Sum of number
````
<numbers>
  <number>33</number>
  <number>34.4</number>
  <number>33.8</number>
  <number>33.43</number>
  <number>34.46</number>
  <number>35</number>
  <number>33.49</number>
  <number>33.00</number>
</numbers>

sum(numbers/number[round(.) = 34])
````

### ...


