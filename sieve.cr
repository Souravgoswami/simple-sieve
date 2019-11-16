 #!/usr/bin/env crystal

def sieve(max)
	sq, executing = 1, true

	Thread.new do
		dot, ary, colours = ".", ["\xE2\xA0\x81", "\xE2\xA0\x88", "\xE2\xA0\xA0", "\xE2\xA0\x84"] * 4, [154, 184, 208, 203, 198, 164, 129, 92].tap { |x| x.concat(x.reverse) }
		text = "Calculating Primes in Range #{comma(max)}"
		ti, ts = 0, text.size - 1

		print "\e[?25l"

		while executing
			ary.size.times do |x|
				if executing
					print(
						" \e[2K#{ary[x]}\e[38;5;#{colours[x]}m \
						#{text[0...ti] + (text[ti].to_s =~ /\d/ ? "\e[4m" : "" )\
						+ swapcase(text[ti]) + "\e[0m\e[38;5;#{colours[x]}m" +\
						text[ti + 1..-1]} (#{sq.*(100)./(max).to_i8.clamp(0, 99).to_s.rjust(2)}%)\e[0m\r"
					)

					ti = 0 if (ti += 1) > ts
					sleep(0.1)
				else
					break
				end
			end
		end
	end

	s = [nil, nil] + (2..max).to_a
	s.each do |x|
		next unless x
		break if (sq = x ** 2) > max
		(sq..max).step(x) { |y| s[y] = nil }
	end

	executing = false
	sleep 0.01
	print "\e[2K\r\e[?25h\e[0m"
	s.tap { |x| x.compact! }
end

def swapcase(text)
	text.upcase == text ? text.downcase : text.upcase
end

def comma(num, char = ",")
	na = ""
	num.to_s.reverse.gsub(/\d{1,3}/) { |x| na += x + char }
	n = na[0..-2].reverse
end

def help
	n = rand(1_000..1_000_000_000)

	<<-EOF
	\e[34;1;4mUsage Example\e[0m:
		#{File.basename(__FILE__)} #{n}
		#{File.basename(__FILE__)} #{comma(n)}
		#{File.basename(__FILE__)} #{comma(n, "_")}

		The above examples will calculate the total number of primes from 2 to #{comma(n)}.

	\e[32;1;4mArguments\e[0m:
		1. Pass \e[35;1;4mlist\e[0m argument to see the list of the primes:
			#{File.basename(__FILE__)} #{comma(n)} list
			#{File.basename(__FILE__)} list #{comma(n, "_")}

		2. Pass \e[35;1;4mlistOnly\e[0m argument to see only the list of the primes:
			#{File.basename(__FILE__)} #{comma(n)} listOnly
			#{File.basename(__FILE__)} listOnly #{comma(n, "_")}

		3. Pass \e[35;1;4mhelp\e[0m argument see this help again.

		Arguments are case insensitive.
	EOF
end

if ARGV.find { |x| x =~ /help$/i }
	puts(help)
	exit

elsif ARGV.find { |x| x.split(/[^\d]/).join.to_i { 0 }.to_s != x.split(/[^\d]/).join } || ARGV.empty?
	abort (<<-EOF)
	\e[31;1m"Bad usage." - #{File.basename(__FILE__)}

	#{help}
	EOF
end


n = ARGV.find { |x| x.split(/[^\d]/).join.to_i { 0 }.to_s == x.split(/[^\d]/).join }
	.to_s.split(/[^\d]/).join.to_i { 0 }

sieves = sieve(n)

if ARGV.find { |x| x =~ /^listOnly$/i }
	puts sieves.join("\n")
else
	sz = comma(sieves.size)
	m = "Total #{sz} Prime Number#{sz == 1 ? "" : "s" } were Found in Range #{comma(n)}"

	puts "List of Primes in Range#{n}:\n#{sieves.join(", ")}\n\e[4m#{" " * m.size}\e[0m" if ARGV.find { |x| x =~ /^list$/i }
	puts "Total #{sz} Prime Number#{sz == 1 ? "" : "s" } #{sz == 1 ? "is" : "were"} Found in Range #{comma(n)}"
end

print "\r\e[?25h\e[0m"
