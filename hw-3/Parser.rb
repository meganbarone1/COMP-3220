# https://www.cs.rochester.edu/~brown/173/readings/05_grammars.txt
#
#
#  "TINY" Grammar
#
# PGM        -->   STMT+
# STMT       -->   ASSIGN   |   "print"  EXP
# ASSIGN     -->   ID  "="  EXP
# EXP        -->   TERM   ETAIL
# ETAIL      -->   "+" TERM   ETAIL  | "-" TERM   ETAIL | EPSILON
# TERM       -->   FACTOR  TTAIL
# TTAIL      -->   "*" FACTOR TTAIL  | "/" FACTOR TTAIL | EPSILON
# FACTOR     -->   "(" EXP ")" | INT | ID
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
load "Token.rb"
load "Lexer.rb"
class Parser < Scanner


	def initialize(filename)
    	super(filename)
    	consume()
	end

	def consume()
      	@lookahead = nextToken()
      	while(@lookahead.type == Token::WS)
        	@lookahead = nextToken()
      	end
	end

	def match(dtype)
      	if (@lookahead.type != dtype)
         	puts "Expected #{dtype} found #{@lookahead.type}"
					@errors+=1
      	end
      	consume()
	end

	def program()
			@errors = 0
      	while( @lookahead.type != Token::EOF)
        	puts "Entering STMT Rule"
					statement()
      	end
				puts "There were #{@errors} parse errors found."

	end

	def statement()
		if (@lookahead.type == Token::PRINT)
			puts "Found PRINT Token: #{@lookahead.text}"
			match(Token::PRINT)
			puts "Entering EXP Rule"
			exp()
		else
			puts "Entering ASSGN Rule"
			assign()
		end

		puts "Exiting STMT Rule"
	end

	def assign()
		if(@lookahead.type == Token::ID)
			puts "Found ID Token: #{@lookahead.text}"
			match(Token::ID)
			if(@lookahead.type == Token::ASSGN)
				puts "Found ASSGN Token: #{@lookahead.text}"
				match(Token::ASSGN)
			else
				puts "Expected = found #{@lookahead.type}"
			end
		else
			match(Token::ID)
		end

		puts "Entering EXP Rule"
		exp()
		puts "Exiting ASSGN Rule"

	end

	def exp()
		puts "Entering TERM Rule"
		term()
		puts "Entering ETAIL Rule"
		etail()
		puts "Exiting EXP Rule"

	end

	def term()
		puts "Entering FACTOR Rule"
		factor()
		puts "Entering TTAIL Rule"
		ttail()
		puts "Exiting TERM Rule"
	end

	def factor()

		if (@lookahead.type == Token::LPAREN)
			puts "Found LPAREN Token: #{@lookahead.text}"
			match(Token::LPAREN)
			puts "Entering EXP Rule"
			exp()
			if (@lookahead.type == Token::RPAREN)
				puts "Found RPAREN Token: #{@lookahead.text}"
				match(Token::RPAREN)
			else
				match(Token::RPAREN)
			end
		elsif (@lookahead.type == Token::INT)
			puts "Found INT Token: #{@lookahead.text}"
			match(Token::INT)

		elsif (@lookahead.type == Token::ID)
			puts "Found ID Token: #{@lookahead.text}"
			match(Token::ID)
		else
			puts "Expected ( or INT or ID found #{@lookahead.text}"
		end
		puts "Exiting FACTOR Rule"
	end



	def ttail()
		if (@lookahead.type == Token::MULTOP)
			puts "Found MULTOP Token: #{@lookahead.text}"
			match(Token::MULTOP)
			puts "Entering FACTOR Rule"
			factor()
			puts "Entering TTAIL Rule"
			ttail()
		elsif (@lookahead.type == Token::DIVOP)
			puts "Found DIVOP Token: #{@lookahead.text}"
			match(Token::DIVOP)
			puts "Entering FACTOR Rule"
			factor()
			puts "Entering TTAIL Rule"
			ttail()
		else
			puts "Did not find MULTOP or DIVOP Token, choosing EPSILON production"
		end
		puts "Exiting TTAIL Rule"
	end

	def etail()
		if (@lookahead.type == Token::ADDOP)
			puts "Found ADDOP Token: #{@lookahead.text}"
			match(Token::ADDOP)
			puts "Entering TERM Rule"
			term()
			puts "Entering ETAIL Rule"
			etail()
		elsif (@lookahead.type == Token::SUBOP)
			puts "Found SUBOP Token: #{@lookahead.text}"
			match(Token::SUBOP)
			puts "Entering TERM Rule"
			term()
			puts "Entering ETAIL Rule"
			etail()
		else
			puts "Did not find ADDOP or SUBOP Token, choosing EPSILON production"
		end
		puts "Exiting ETAIL Rule"
	end

end
