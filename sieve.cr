 #!/usr/bin/env crystal
# GC.disable

def sieve(max)
	sq, executing = 1, true
	text = "Initializing Array!"

	Thread.new do
		dot, ary = '.', ["\xE2\xA0\x81", "\xE2\xA0\x88", "\xE2\xA0\xA0", "\xE2\xA0\x84"] * 4
		colours, ti =[154, 184, 208, 203, 198, 164, 129, 92].tap { |x| x.concat(x.reverse) }, 0

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

					ti = 0 if (ti += 1) > text.size - 1
					sleep(0.1)
				else
					break
				end
			end
		end
	end

	s = [] of UInt32 | Nil
	mm = max.to_u32 + 1

	index = 2u32

	GC.disable
	while index < mm
		s.push(index)
		index += 1
	end
	GC.enable
	s.unshift(nil, nil)

	ccc, m = 1, (max + 1).to_u32

	text = "Calculating Primes in Range #{comma(max)}"

	while (sq = (ccc += 1) ** 2) < max
		next unless x = s[ccc]

		temp = sq
		while temp < m
			s[temp], temp = nil, temp + x
		end
	end

	executing = false
	print "\e[2K\r\e[?25h\e[0m"
	s.compact!
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
elsif ARGV.empty? || !ARGV.find { |x| x.split(/[^\d]/).join.to_i { 0 }.to_s == x.split(/[^\d]/).join }
	abort (<<-EOF)
	\e[31;1m"Bad usage." - #{File.basename(__FILE__)}

	#{help}
	EOF
end

n = ARGV.find { |x| x.split(/[^\d]/).join.to_i { 1 }.to_s == x.split(/[^\d]/).join }
	.to_s.split(/[^\d]/).join.to_i { 1 }
sieves = sieve(n)

if ARGV.find { |x| x =~ /^listOnly$/i }
	puts sieves.join("\n")

else
	sz = comma(sieves.size)
	m = "Total #{sz} Prime Number#{sz == 1 ? "" : "s" } were Found in Range #{comma(n)}"

	puts "List of Primes in Range #{n}:\n#{sieves.join(", ")}\n\e[4m#{" " * m.size}\e[0m" if ARGV.find { |x| x =~ /^list$/i }
	puts "Total #{sz} Prime Number#{sz == 1 ? "" : "s" } #{sz == 1 ? "is" : "were"} Found in Range #{comma(n)}"
end

print "\r\e[?25h\e[0m"
