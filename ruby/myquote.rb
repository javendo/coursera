class Quote
	require 'open-uri'

	@@cache_cetip_tax = [nil, 0]
	
	def initialize(symbol="PETR4")
		@symbol=symbol
	end
	
	def get_quote
		name=price=openprice=variation=nil
		url="http://br.advfn.com/p.php?pid=chartinfo&symbol=#{@symbol}"
		open(url).each do |line|
			name=($1 if /^0NAME_WITH_CURRENCY~(.+)$/ =~line) if name.nil?
			price=($1.to_f if /^0CUR_PRICE~(.+)$/ =~line) if price.nil?
			openprice=($1.to_f if /0OPEN_PRICE~(.+)$/ =~line) if openprice.nil?
		end
		variation=(price / openprice - 1) * 100
		[price, openprice, variation]
	end
	
	def get_volatility(ndays=0)
		df = Time.now
		di = df - ndays * 60 * 60 * 24
		main_symbol = @symbol[0, 4] + (@symbol[0, 4] == "VALE" ? "5" : "4")
		url = "http://ichart.finance.yahoo.com/table.csv?s=#{main_symbol}.SA&a=#{di.month - 1}&b=#{di.day}&c=#{di.year}&d=#{df.month - 1}&e=#{df.day}&f=#{df.year}&g=d&ignore=.csv"
		values = []
		open(url).to_a[1 .. -1].each do |line|
			temp = line.split(",")
			values << temp[temp.length - 1].to_f
		end
		standard_deviation(values)
	end
	
	def get_cetip_tax()
		now = Time.now
		if (@@cache_cetip_tax[0].nil? || now - @@cache_cetip_tax[0] > 1 * 60 * 60 * 24)
			5.times do |i|
				begin
					url = "ftp://ftp.cetip.com.br/MediaCDI/#{(now -  i * 60 * 60 * 24).strftime("%Y%m%d")}.txt"
					@@cache_cetip_tax = [Time.now, open(url).string.to_f / 100]
					break
				rescue
					#nao faz nada, simplesmente vai pra proxima data
				end
			end
		end
		@@cache_cetip_tax[1]
	end

	private
	def standard_deviation(values=[])
		count = values.size
		mean = values.inject(:+) / count.to_f
		puts mean
		Math.sqrt(values.inject(0) { |sum, e| sum + (e - mean) ** 2 } / count.to_f )
	end
	
end


#t1 = Thread.new {
	qpetro=Quote.new("PETRB36")
	#puts qpetro.get_quote
	puts qpetro.get_volatility(45)
	#puts qpetro.get_cetip_tax
#}


#t2 = Thread.new {
	qvale=Quote.new("VALE5")
	#puts qvale.get_quote
	puts qvale.get_volatility(45)
	#puts qvale.get_cetip_tax
#}
