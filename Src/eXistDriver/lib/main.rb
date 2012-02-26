#DEMO aplikace Ruby eXist driveru
$:.unshift("C:/Users/sirljan/Documents/NetBeansProjects/eXistDriver/lib")
require "database_manager"
include REXML

# pripojeni k databazi

db = DatabaseManager.new("http://localhost:8080/exist/xmlrpc", "admin", "admin")

#ziskame kolekci Shakespearovych her
col = db.getcollection("/db/pokus/")
#
# relativni a absolutni cesta ke kolekci v db
puts col.getname
puts col.geturi
#
##vytvorime kolekci jejiz rodicem bude col
#db.createcollection("ACL", col)
#
##vypis podkolekci
#puts "Vypis podkolekci kolekce" + col.getname
#puts col.listchildcollections
#vypis dokumnetu v kolekci
puts "Vypis dokumentu v kolekci" + col.getname
puts col.listresources

query = <<END
for $country in /mondial/country
where some $r in $country/religions satisfies $r = "Roman Catholic"
order by $country/religions[. = "Roman Catholic"]/@percentage cast as xs:double descending
return
  <country name="{$country/name}">
    {$country/religions}
  </country>
END

puts db.execute_query(query)
db.update_insert('<country>Czech Republic</country>', "into", '//cities/city[name="Praha"]')


#
##ziskani rodice kolekce
#par = col.getparentcollection
#puts "Rodic kolekce" + col.getname + "je"
#puts par.getname
#
#
###nacteme xml soubor, ktery chceme ulozit
#xmlfile = File.new("xmlfile.xml")
#xmldoc = Document.new(xmlfile)
##
###ulozeni xml souboru
#resname = col.getname + "xmlfile.xml"
#col.storeresource(xmldoc, resname)
###a presvedcime se, ze tam skutecne je
#puts "Vypis dokumentu v kolekci" + col.getname + ", meli bychom tam videt nas novy dokument"
#puts col.listresources

##xUpdate dokumentu / nefunguje - pouzit alternativu / xquery a update
#docname = col.getname + "cities.xml"
#xupdate = Document.new(File.new("mojexml.xml"))
#col.updateresource(docname, xupdate)

#
#
##nacteni dokumentu zpet s danymi parametry
#parameters = {'encoding' => 'UTF-8', 'prety' => 1}
#col.parameters=(parameters)
#puts "Nas zpatky nacteny dokument:"
#res = col.getresource(resname)
#puts res
#
#
##vytvorime kolekci jejiz rodicem bude col
#db.createcollection("testCollection", col)
#
#
## koukneme se, jestli se objevila ve vypisu
#desc = col.listchildcollections
#puts "Vypis podkolekci kolekce" + col.getname
#puts desc
#
## zkusime si ji vzit
#child = col.getchildcollection("testCollection")
#puts child.getname
#
#
##vlozime do kolekce novy xml dokument
#childresname = child.getname + "xmlfile.xml"
#puts childresname
#child.storeresource(xmldoc, childresname)
#
#
## a uz bychom ho tam meli videt
#puts "Obsah kolekce" + child.getname + ":"
#puts child.listresources
#
#
##a zas pryc s nim
#child.removeresource(childresname)
#puts "Obsah kolekce" + child.getname + "po smazani dokumentu:"
#puts child.listresources
#
#
#odstanime nasi kolekci
#db.removecollection(child.getname)
#
## a zkontrolujeme, zda je skutecne pryc
#desc = col.listchildcollections
#puts "Potomci kolekce " + child.getname + ": po smazani testCollection"
#puts desc
