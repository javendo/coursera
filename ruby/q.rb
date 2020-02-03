require 'net/http'
require 'rexml/document'

REXML::Document.new(Net::HTTP.get_response(
  URI.parse("http://www.bmfbovespa.com.br/Pregao-Online/ExecutaAcaoAjax.asp?CodigoPapel=IBOV%7C#{ARGV.join('%7C').upcase}&intEstado=1")).body).elements.each('ComportamentoPapeis/Papel') { |e| printf "%-8s %-25s %-26s %+10s %+10s %+10s %+10s %+10s %+10s%% \n", e.attribute('Codigo'), e.attribute('Nome'), e.attribute('Data'), e.attribute('Abertura'), e.attribute('Minimo'), e.attribute('Maximo'), e.attribute('Medio'), e.attribute('Ultimo'), e.attribute('Oscilacao')}
