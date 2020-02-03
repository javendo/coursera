###
# Busca a cotação on-line de uma lista de ativos no site da bovespa e fica imprimindo na tela
#
#  09/03/27 tkuma: Inserido tempo da cotação
#  09/04/10 aamaral: Refatoracao - (ticker funcionando, cores e opcoes de linha de comando)
#                    Para funcionar cores no windows, é preciso instalar o modulo win32console:
#
#                    >gem install win32console
# ----------------------------------------------------------------------------------------------
#
# TODO:
#  - multi-threading
#  - implementar display (n)curses para funcionar cores em outros SOs
#  - implementar display GUI com Tk
#  - implementar novos data sources e melhorar o ADVFN que tá meio bugado
#
###

require 'open-uri'

class Quote 
    
  attr_accessor :symbol, :price, :variation, :last_updated

  def initialize(symbol = "????", ds = nil)
    @symbol = symbol.upcase
    @price = @variation = 0
    @last_updated = "00:00:00"
    @ds = ds
  end

  def update!
    #price = var = last_up = nil
    begin
      price, var, last_up = @ds.get_quote @symbol
    rescue Exception => e
      last_up = nil
    ensure
      @last_updated = last_up unless last_up.nil? 
      @price =  price unless price.nil? 
      @variation = var unless var.nil? 
    end
    !last_up.nil?
  end

  def get_formatted
    update!
    sprintf("%-8s %10.2f %+10.2f%% \t %-8s \n", @symbol, @price, @variation, @last_updated)
  end

  def print
    puts get_formatted
  end

end

###
# Data sources
#
class DS
    
  def self.get_named_ds(name)
    case name.upcase
      when 'BOV'
        BovespaDS.new
      when 'ADVFN'
        AdvfnDS.new
      else
        puts "Fonte de dados desconhecida \"#{name}\" - assumindo default"
        BovespaDS.new
    end
  end

  def get_quote(symbol)
    price = var = last_up = nil
    open get_url(symbol) do |f|
      f.each do |line|
        price = match_price line if price.nil?
        var = match_variation line if var.nil?
        last_up = match_last_up line if last_up.nil? 
        break if !last_up.nil? && !price.nil? && !var.nil?
      end
    end
    return price, var, last_up
  end

end

class BovespaDS < DS
  def match_price(s)
    s =~ /R\$\s*(\d*\.*\d+,\d+)/ ? $1.gsub!(/,/, '.').to_f : nil
  end

  def match_variation(s)
    s =~ /(\-*\d+,\d+)%/ ? $1.gsub!(/,/, '.').to_f : nil
  end

  def match_last_up(s)
    s =~ /"spnDataCotacao">([0-9]{2}:[0-9]{2}:[0-9]{2})/ ? $1 : nil
  end

  def get_url(symbol)
    "http://www.bovespa.com.br/home/ExecutaAcaoCotRapXSL.asp?txtCodigo=#{symbol}&intIdiomaXsl=0"
  end
end

class AdvfnDS < DS
  def match_price(s)
    s =~ /BOV:.*>(\-{0,1}\d+\.\d+)<.*>(\-{0,1}\d+\.\d+)</  ? $1.to_f : nil
  end

  def match_variation(s)
    s =~ /BOV:.*>(\-{0,1}\d+\.\d+)<.*>(\-{0,1}\d+\.\d+)</  ? $2.to_f : nil
  end

  def match_last_up(s)
    s =~ />(\d{2}:\d{2}:\d{2})</ ? $1 : nil
  end
    
  def get_url(symbol)
    "http://br.advfn.com/p.php?pid=chartinfo&symbol=#{symbol}"
  end
end

###
# Displays
#
class Display
    
  def self.new_instance
    if RUBY_PLATFORM =~ /win32/ 
      Win32Display.new 
    elsif RUBY_PLATFORM =~ /n.x/ 
      CursesDisplay.new
    else
      Display.new
    end
  end

  def print_quote(row, quote)
    quote.print
  end

  def clear
  end
  
end

class Win32Display < Display

  if RUBY_PLATFORM =~ /win32/
    require 'win32Console' 
  #require "Term/ANSIColor"
    include Term::ANSIColor
  end

  def initialize
    @out = Win32::Console.new STD_OUTPUT_HANDLE
    @out.Title "Bovespa ticker"
    @out.Cls
  end
    
  # saudades do clipper...  
  def say(x, y, *args)
    @out.Cursor y, x, 0, 1
    print *args
  end
    
  def print_quote(row, quote)
    say row,  0, bold, quote.symbol
    say row, 10, reset, sprintf("%10.2f", quote.price)
    say row, 22, bold, (quote.variation > 0 ? green : quote.variation < 0 ? red : white), sprintf("%+10.2f%%", quote.variation)
    say row, 42, reset, quote.last_updated
  end

  def clear
    @out.Cls
  end
end

class CursesDisplay < Display
  #TODO
end

###
# Main class 
#
class Ticker

  def prepare
    return usage unless ARGV.length > 0 
    
    @run_once = true
    @interval = 5
    ds_name = 'BOV'
    
    while ARGV[0] =~ /^\-+.+$/
      case p = ARGV.shift
        when '-h', '--help'
          return usage
        when '-t', '--ticker'
          @run_once = false
        when '-i'
          @interval = ARGV.shift.to_i
        when /^\-\-interval=(.*)/
          @interval = $1.to_i
        when '-s'
          ds_name = ARGV.shift
        when /^\-\-source=(.*)/
          ds_name = $1
        else
          puts "Parametro desconhecido \"#{p}\"\n\n"
          return usage
      end
    end
    
    ds = DS.get_named_ds(ds_name)
    
    @quotes = []
    ARGV.each {|symbol| @quotes.push Quote.new(symbol, ds) unless symbol.length < 4}

    unless @quotes.length == 0 
    1 else
      puts "Nenhum ativo especificado\n\n"
      usage
    end
  
  end

  def interval
    @interval*60
  end

  def display_quotes(update = true)
    row = 0
    @quotes.each do |quote| 
      @display.print_quote row, quote if !update || (update && quote.update!)
      row += 1
    end
  end

  def run_ticker
    @display = Display.new_instance
    
    trap("INT") do
      @display.clear
      exit
    end
    
    display_quotes false    
    loop do
      display_quotes
      sleep interval
    end
    
  end

  def run_once
    @display = Display.new
    display_quotes
  end

  def run
    return unless prepare
    @run_once ? run_once : run_ticker
  end

  def usage
    puts "Uso: quote.rb [OPCOES]... [ATIVOS]..."
    puts "Mostra cotacoes de ativos negociados na Bovespa com atraso de 15 minutos"
    puts ""
    puts "  -t, --ticker        fica atualizando as cotacoes no tempo definido pela opcao -i, caso"
    puts "                      contrario, mostra as cotacoes uma unica vez e sai"
    puts "  -s, --source=NAME   nome da fonte dos dados, pode ser BOV (default) ou ADVFN"
    puts "  -i, --interval=N    quando utilizado com -t, N diz o intervalo (em minutos) para"
    puts "                      atualizacao das cotacoes"
    puts "  -h, --help          mostra essa tela"
    puts ""
    false
  end

end

Ticker.new.run
