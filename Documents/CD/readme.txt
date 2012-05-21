Pro úspěšné zprovoznění mnou naimplementované knihovny, která spravuje přístupo-
vá práva, musíte nejprve nainstalovat software, na kterém je knihovna závislá. 
Jedná se o:
• Ruby prostředí - http://www.ruby-lang.org/en/downloads/
    Na příslušné stránce vyberte distribuci podle vašeho operačního systému. 
    Pro windows je nejlepší řešení RubyInstaller. Nainstalujte nejnovější verzi. 
    V době vydání knihovny byla nejnovějčí verze Ruby 1.9.3.-p194.  Při instala-
    ci zaškrtněte "Add Ruby executables to your PATH".
• JDK 
    http://www.oracle.com/technetwork/java/javase/downloads/jdk-7u4-downloads-1591156.html
    Databáze eXist-db pro svůj běh potřebuje Java Development Kit. JRE není dos-
    tačující.
• Databázi eXist-db - http://exist-db.org/exist/download.xml
    Doporučuji stáhnout "Stable release". V době vydání byla dostupná verze eXi-
    st-setup-1.4.2-rev16251.

Dále potřebujete nainstalovat samotnou knihovnu a eXistAPI rozhraní.
Nejjednodušším způsobem, jak nainstalovat knihovnu a komunikační rozhraní pro eXist-db, je nainstalovat Ruby prostředí včetně balíčkovacího systému gem a nainstalovat jak knihovnu, tak rozhraní pomocí příkazů "gem install Ruby-ACL" (pomlčka je podstatná, protože "rubyacl" je gem, který s mojí knihovnou nemá nic společného) a "gem install eXistAPI". Příkazy lze použít ve standartní příkazové řádce, pokud jste zaškrtli při instalaci volbu "Add Ruby executables to your PATH". 

Dalším způsobem, jak používat knihovnu s rozhraním je, stáhnout si zdrojové kódy buď z CD nebo z githubu. Zdrojové kódy Ruby-ACL se nachází na https://github.com/sirljan/Ruby-ACL a zdrojové kódy eXistAPI jsou na https://github.com/sirljan/eXistAPI. V případě stažení kódu z githubu je důležité použít příkaz "require" se správnou adresou ke zdrojovým souborům. 

Poznámka: Výchozí adresy, ze kterých "require" vkládá soubory, jsou aktuální adresář a adresář, kde se ukládají gem. Proto, když si gem nainstalujete přes rubygem, není potřeba řešit adresy, stačí použít příkazy "require 'Ruby-AL'" a "require 'eXistAPI'".

Před použitím spusťte eXist-db. Funkčnost můžete ověřit třeba v irb - Interactive Ruby Shell zavoláním příkazů:
require 'Ruby-ACL'
require 'eXistAPI'
@db = ExistAPI.new("http://localhost:8080/exist/xmlrpc", "admin", "password")
@my_acl = RubyACL.new("my_acl", @db)
@my_acl.create_principal("Sheldon")

Po spuštění těchto příkazů najdete pomocí eXist Admin Clientu, v kolekci "/db/acl/" dokument  Principals.xml, ve kterém by měl být (jako poslední v uzlu Individuals) uzel s id="Sheldon". Pokud uzel v dokumentu není, něco bylo chybně provedeno.



OBSAH PŘILOŽENÉHO CD
.
|-- abstract                     - adresář s abstraktem v čj a aj
|   |-- abstract.html            - krátky abstract
|   |-- RabstractAJ.html         - rozšířený abstract v angličtině
|   `-- RabstractCZ.html         - rozšířený abstract v češtině
|-- gem                          - adresář obsahující instalační balíčky gem
|-- index.html                   - výchozí stránka projektu - z ní realtivní 
|                                html odkazy na dokumentaci, zdrojové 
|                                texty a exe soubor
|-- install.TXT                  - postup instalace knihovny
|-- rdoc                         - adresář s rdoc dokumentací
|   |-- eXistAPI                 - rdoc dokumentace k eXistAPI
|   |   |-- index.html           - výchozí stránka dokumentace eXistAPI  
|   |   `-- ...                  - další soubory a stránky dokumentace
|   |   |-- images               - obrázky/ikony dokumentace
|   |   |   `-- ...
|   `-- Ruby-ACL                 - rdoc dokumentace k Ruby-ACL
|       |-- index.html           - výchozí stránka dokumentace Ruby-ACL 
|       `-- ...                  - další soubory a stránky dokumentace
|       |-- images               - obrázky/ikony dokumentace
|           `-- ...
|-- readme.TXT                   - popis, co ve kterém adresáři je a jaký je účel jednotlivých souborů, postup spuštění
|-- src                          - adresář zdrojových souborů eXistAPI a Ruby-ACL
|   |-- eXistAPI
|   |   `-- ...                  - zdrojové soubory eXistAPI
|   `-- Ruby-ACL                        
|       |-- ...                  - zdrojové soubory Ruby-ACL
|       `-- src_files                   
|           `-- ...              - datové XML soubory a jejich DTD
`-- text                         - adresář obsahující vlastní text BP
    `-- sirljan-thesis-2012.pdf  - text BP ve formátu PDF
    
18 directories, 122 files