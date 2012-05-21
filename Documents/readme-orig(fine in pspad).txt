Pro úspì¹né zprovoznìní mnou naimplementované knihovny, která spravuje pøístupová práva, musíte nejprve nainstalovat software, na kterém je knihovna závislá. 
Jedná se o:
• Ruby prostøedí - http://www.ruby-lang.org/en/downloads/
    Na pøíslu¹né stránce vyberte distribuci podle va¹eho operaèního systému. 
    Pro windows je nejlep¹í øe¹ení RubyInstaller. Nainstalujte nejnovìj¹í verzi. 
    V dobì vydání knihovny byla nejnovìjèí verze Ruby 1.9.3.-p194.  Pøi instala-
    ci za¹krtnìte "Add Ruby executables to your PATH".
• JDK 
    http://www.oracle.com/technetwork/java/javase/downloads/jdk-7u4-downloads-1591156.html
    Databáze eXist-db pro svùj bìh potøebuje Java Development Kit. JRE není dos-
    taèující.
• Databázi eXist-db - http://exist-db.org/exist/download.xml
    Doporuèuji stáhnout "Stable release". V dobì vydání byla dostupná verze eXi-
    st-setup-1.4.2-rev16251.

Dále potøebujete nainstalovat samotnou knihovnu a eXistAPI rozhraní.
Nejjednodu¹¹ím zpùsobem, jak nainstalovat knihovnu a komunikaèní rozhraní pro eXist-db, je nainstalovat Ruby prostøedí vèetnì balíèkovacího systému gem a nainstalovat jak knihovnu, tak rozhraní pomocí pøíkazù "gem install Ruby-ACL" (pomlèka je podstatná, proto¾e "rubyacl" je gem, který s mojí knihovnou nemá nic spoleèného) a "gem install eXistAPI". Pøíkazy lze pou¾ít ve standartní pøíkazové øádce, pokud jste za¹krtli pøi instalaci volbu "Add Ruby executables to your PATH". 

Dal¹ím zpùsobem, jak pou¾ívat knihovnu s rozhraním je, stáhnout si zdrojové kódy buï z CD nebo z githubu. Zdrojové kódy Ruby-ACL se nachází na https://github.com/sirljan/Ruby-ACL a zdrojové kódy eXistAPI jsou na https://github.com/sirljan/eXistAPI. V pøípadì sta¾ení kódu z githubu je dùle¾ité pou¾ít pøíkaz "require" se správnou adresou ke zdrojovým souborùm. 

Poznámka: Výchozí adresy, ze kterých "require" vkládá soubory, jsou aktuální adresáø a adresáø, kde se ukládají gem. Proto, kdy¾ si gem nainstalujete pøes rubygem, není potøeba øe¹it adresy, staèí pou¾ít pøíkazy "require 'Ruby-AL'" a "require 'eXistAPI'".

Pøed pou¾itím spus»te eXist-db. Funkènost mù¾ete ovìøit tøeba v irb - Interactive Ruby Shell zavoláním pøíkazù:
require 'Ruby-ACL'
require 'eXistAPI'
@db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")
@my_acl = RubyACL.new("my_acl", @db)
@my_acl.create_principal("Sheldon")

Po spu¹tìní tìchto pøíkazù najdete pomocí eXist Admin Clientu, v kolekci "/db/acl/" dokument  Principals.xml, ve kterém by mìl být (jako poslední v uzlu Individuals) uzel s id="Sheldon". Pokud uzel v dokumentu není, nìco bylo chybnì provedeno.



OBSAH PØILO®ENÉHO CD
.
|-- abstract                     - adresáø s abstraktem v èj a aj
|   |-- abstract.html            - krátky abstract
|   |-- RabstractAJ.html         - roz¹íøený abstract v angliètinì
|   `-- RabstractCZ.html         - roz¹íøený abstract v èe¹tinì
|-- gem                          - adresáø obsahující instalaèní balíèky gem
|-- index.html                   - výchozí stránka projektu - z ní realtivní 
|                                html odkazy na dokumentaci, zdrojové 
|                                texty a exe soubor
|-- install.TXT                  - postup instalace knihovny
|-- rdoc                         - adresáø s rdoc dokumentací
|   |-- eXistAPI                 - rdoc dokumentace k eXistAPI
|   |   |-- index.html           - výchozí stránka dokumentace eXistAPI  
|   |   `-- ...                  - dal¹í soubory a stránky dokumentace
|   |   |-- images               - obrázky/ikony dokumentace
|   |   |   `-- ...
|   `-- Ruby-ACL                 - rdoc dokumentace k Ruby-ACL
|       |-- index.html           - výchozí stránka dokumentace Ruby-ACL 
|       `-- ...                  - dal¹í soubory a stránky dokumentace
|       |-- images               - obrázky/ikony dokumentace
|           `-- ...
|-- readme.TXT                   - popis, co ve kterém adresáøi je a jaký je úèel jednotlivých souborù, postup spu¹tìní
|-- src                          - adresáø zdrojových souborù eXistAPI a Ruby-ACL
|   |-- eXistAPI
|   |   `-- ...                  - zdrojové soubory eXistAPI
|   `-- Ruby-ACL                        
|       |-- ...                  - zdrojové soubory Ruby-ACL
|       `-- src_files                   
|           `-- ...              - datové XML soubory a jejich DTD
`-- text                         - adresáø obsahující vlastní text BP
    `-- sirljan-thesis-2012.pdf  - text BP ve formátu PDF
    
18 directories, 122 files