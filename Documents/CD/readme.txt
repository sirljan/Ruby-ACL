Pro úspìšné zprovoznìní mnou naimplementované knihovny, která spravuje pøístupová práva, musíte nejprve nainstalovat software, na kterém je knihovna závislá. 
Jedná se o:
• Ruby prostøedí - http://www.ruby-lang.org/en/downloads/
    Na pøíslušné stránce vyberte distribuci podle vašeho operaèního systému. Pro windows je nejlepší øešení RubyInstaller. Nainstalujte nejnovìjší verzi. V dobì vydání knihovny byla nejnovìjèí verze Ruby 1.9.3.-p194.  Pøi instala ci zaškrtnìte "Add Ruby executables to your PATH".
• JDK 
    http://www.oracle.com/technetwork/java/javase/downloads/jdk-7u4-downloads-1591156.html
    Databáze eXist-db pro svùj bìh potøebuje Java Development Kit. JRE není dostaèující.
• Databázi eXist-db - http://exist-db.org/exist/download.xml
    Doporuèuji stáhnout "Stable release". V dobì vydání byla dostupná verze eXist-setup-1.4.2-rev16251.

Dále potøebujete nainstalovat samotnou knihovnu a eXistAPI rozhraní.
Nejjednodušším zpùsobem, jak nainstalovat knihovnu a komunikaèní rozhraní pro eXist-db, je nainstalovat Ruby prostøedí vèetnì balíèkovacího systému gem a nainstalovat jak knihovnu, tak rozhraní pomocí pøíkazù "gem install Ruby-ACL" (pomlèka je podstatná, protoe "rubyacl" je gem, kterı s mojí knihovnou nemá nic spoleèného) a "gem install eXistAPI". Pøíkazy lze pouít ve standartní pøíkazové øádce, pokud jste zaškrtli pøi instalaci volbu "Add Ruby executables to your PATH". 

Dalším zpùsobem, jak pouívat knihovnu s rozhraním je, stáhnout si zdrojové kódy buï z CD nebo z githubu. Zdrojové kódy Ruby-ACL se nachází na https://github.com/sirljan/Ruby-ACL a zdrojové kódy eXistAPI jsou na https://github.com/sirljan/eXistAPI. V pøípadì staení kódu z githubu je dùleité pouít pøíkaz "require" se správnou adresou ke zdrojovım souborùm. 

Poznámka: Vıchozí adresy, ze kterıch "require" vkládá soubory, jsou aktuální adresáø a adresáø, kde se ukládají gem. Proto, kdy si gem nainstalujete pøes rubygem, není potøeba øešit adresy, staèí pouít pøíkazy "require 'Ruby-AL'" a "require 'eXistAPI'".

Pøed pouitím spuste eXist-db. Funkènost mùete ovìøit tøeba v irb - Interactive Ruby Shell zavoláním pøíkazù:
require 'Ruby-ACL'
require 'eXistAPI'
@db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")
@my_acl = RubyACL.new("my_acl", @db)
@my_acl.create_principal("Sheldon")

Po spuštìní tìchto pøíkazù najdete pomocí eXist Admin Clientu, v kolekci "/db/acl/" dokument  Principals.xml, ve kterém by mìl bıt (jako poslední v uzlu Individuals) uzel s id="Sheldon". Pokud uzel v dokumentu není, nìco bylo chybnì provedeno.



OBSAH PØILOENÉHO CD
.
|-- abstract                     - adresáø s abstraktem v èj a aj
|   |-- abstract.html            - krátky abstract
|   |-- RabstractAJ.html         - rozšíøenı abstract v angliètinì
|   `-- RabstractCZ.html         - rozšíøenı abstract v èeštinì
|-- gem                          - adresáø obsahující instalaèní balíèky gem
|-- index.html                   - vıchozí stránka projektu - z ní realtivní 
|                                html odkazy na dokumentaci, zdrojové 
|                                texty a exe soubor
|-- install.TXT                  - postup instalace knihovny
|-- rdoc                         - adresáø s rdoc dokumentací
|   |-- eXistAPI                 - rdoc dokumentace k eXistAPI
|   |   |-- index.html           - vıchozí stránka dokumentace eXistAPI  
|   |   `-- ...                  - další soubory a stránky dokumentace
|   |   |-- images               - obrázky/ikony dokumentace
|   |   |   `-- ...
|   `-- Ruby-ACL                 - rdoc dokumentace k Ruby-ACL
|       |-- index.html           - vıchozí stránka dokumentace Ruby-ACL 
|       `-- ...                  - další soubory a stránky dokumentace
|       |-- images               - obrázky/ikony dokumentace
|           `-- ...
|-- readme.TXT                   - popis, co ve kterém adresáøi je a jakı je úèel jednotlivıch souborù, postup spuštìní
|-- src                          - adresáø zdrojovıch souborù eXistAPI a Ruby-ACL
|   |-- eXistAPI
|   |   `-- ...                  - zdrojové soubory eXistAPI
|   `-- Ruby-ACL                        
|       |-- ...                  - zdrojové soubory Ruby-ACL
|       `-- src_files                   
|           `-- ...              - datové XML soubory a jejich DTD
`-- text                         - adresáø obsahující vlastní text BP
    `-- sirljan-thesis-2012.pdf  - text BP ve formátu PDF
    
18 directories, 122 files