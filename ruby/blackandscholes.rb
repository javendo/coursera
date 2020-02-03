#!/usr/bin/ruby
#spot_price -> PrecoAtivo
#price -> PrecoExercicio
#volatility -> Volatilidade
#interest_rate -> TaxaJuros
#time_to_maturity -> Tempo


class BlackAndScholes
	Pi = Math.acos(-1)
	
	def initialize(spot_price, price, volatility, interest_rate, time_to_maturity)
		@spot_price = spot_price
		@price = price
		@volatility = volatility
		@interest_rate = interest_rate
		@time_to_maturity = time_to_maturity
		@p1 = (Math.log(@spot_price / @price) + (@interest_rate + (@volatility ** 2 / 2)) * @time_to_maturity) / (@volatility * Math.sqrt(@time_to_maturity))
		@p2 = @p1 - @volatility * Math.sqrt(@time_to_maturity)
	end
	
	def delta
		ncd(@p1)
	end
	
	def gamma
		(1 / Math.sqrt(2 * Pi) * Math.exp(-@p1 ** 2 / 2)) / (@spot_price * @volatility * Math.sqrt(@time_to_maturity))
	end
	
	def theta
		(-@spot_price * (1 / Math.sqrt(2 * Pi) * Math.exp(-@p1 ** 2 / 2)) * @volatility / (2 * Math.sqrt(@time_to_maturity))) + (-@interest_rate * @price * Math.exp(-@interest_rate * @time_to_maturity) * ncd(@p2))
	end
	
	def vega
		@spot_price * Math.sqrt(@time_to_maturity) * (1 / Math.sqrt(2 * Pi) * Math.exp(-@p1 ** 2 / 2))
	end
	
	def rho
		@price * @time_to_maturity * Math.exp(-@interest_rate * @time_to_maturity) * ncd(@p2)
	end
	
	def implied_volatility(actual_price)
		a = 0, b = 2, eps = 10 ** (-5), n = 1
		volatility = (a + b) / 2
		diff = actual_price - price_bs
		Do While diff.abs > eps && n <= 100
			if diff > 0
				a = volatility
			else
				b = volatility
			end
			volatility = (a + b) / 2
			diff = actual_price - price_bs
			n = n + 1
		Loop
		n > 100 ? "Limite Atingido" : volatility
	end
	
	def price_bs
		@spot_price * delta - @price * Math.exp(-@interest_rate * @time_to_maturity) * ncd(@p2)
	end

	private
	def ncd(x) #normal cumulative distribution
		b1 = 0.319381530
		b2 = -0.356563782
		b3 = 1.781477937
		b4 = -1.821255978
		b5 = 1.330274429
		p = 0.2316419
		c = 0.39894228
		factor = (x >= 0) ? 1 : -1
		t = 1.0 / (1.0 + factor * p * x)
		factor * ((factor + 1) / 2 - c * Math.exp(-x * x / 2.0) * t * (t * (t * (t * (t * b5 + b4) + b3) + b2) + b1));
	end
end

#A volatilidade 
bs = BlackAndScholes.new 33.87, 35.83, 1.39485985215, 0.0862, 12.0 / 252.0 #Preco do ativo, Preco de Exercicio, Volatilidade, Taxa de Juros, Tempo
puts "delta = #{bs.delta}"
puts "gamma = #{bs.gamma}"
puts "vega = #{bs.vega}"
puts "theta = #{bs.theta / 252}"
puts "rho = #{bs.rho}"
puts bs.price_bs
