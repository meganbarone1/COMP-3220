# https://www.cs.rochester.edu/~brown/173/readings/05_grammars.txt
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
# EPSILON    -->   ""
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
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
            puts "Expected #{dtype} found #{@lookahead.text}"
			@errors_found+=1
        end
        consume()
    end

    def program()
    	@errors_found = 0

		p = AST.new(Token.new("program","program"))

	    while( @lookahead.type != Token::EOF)
          statement = statement()
            p.addChild(statement)
        end

        puts "There were #{@errors_found} parse errors found."

		return p
    end

    def statement()
		stmt = AST.new(Token.new("statement","statement"))
        if (@lookahead.type == Token::PRINT)
			stmt = AST.new(@lookahead)
            match(Token::PRINT)
            exp = exp()
            stmt.addChild(exp)
        else
            stmt = assign()
        end
		return stmt
    end

    def exp()
        firstterm = term()
        if(@lookahead.type == Token::ADDOP or @lookahead.type == Token::SUBOP)
          op = etail()
          op.addChild(firstterm)
          return op
        end
        return firstterm
    end

    def term()
        firstfactor = factor()
        if(@lookahead.type == Token::MULTOP or @lookahead.type == Token::DIVOP)
          op = ttail()
          op.addChild(firstfactor)
          return op
        end
        return firstfactor
    end

    def factor()
        fct = AST.new(Token.new("factor", "factor"))
        if (@lookahead.type == Token::LPAREN)
            match(Token::LPAREN)
            fct = exp()
            if (@lookahead.type == Token::RPAREN)
                match(Token::RPAREN)
            else
				match(Token::RPAREN)
            end
        elsif (@lookahead.type == Token::INT)
            fct = AST.new(@lookahead)
            match(Token::INT)
        elsif (@lookahead.type == Token::ID)
            fct = AST.new(@lookahead)
            match(Token::ID)
        else
            puts "Expected ( or INT or ID found #{@lookahead.text}"
            @errors_found+=1
            consume()
        end
		return fct
    end

    def ttail()
        op = AST.new(Token.new("op", "op"))
        if (@lookahead.type == Token::MULTOP)
            op = AST.new(@lookahead)
            match(Token::MULTOP)
            op.addChild(factor())
            next_op = ttail()
            if (next_op != nil)
              op.addChild(next_op)
            end
        elsif (@lookahead.type == Token::DIVOP)
            op = AST.new(@lookahead)
            match(Token::DIVOP)
            op.addChild(factor())
            next_op = ttail()
            if (next_op != nil)
              op.addChild(next_op)
            end

		    else
			       return nil
        end
        return op
    end

    def etail()
        op = AST.new(Token.new("op", "op"))
        if (@lookahead.type == Token::ADDOP)
            op = AST.new(@lookahead)
            match(Token::ADDOP)
            op.addChild(term())
            next_op = etail()
            if (next_op != nil)
              op.addChild(next_op)
            end
        elsif (@lookahead.type == Token::SUBOP)
            op = AST.new(@lookahead)
            match(Token::SUBOP)
            op.addChild(term())
            next_op = etail()
            if (next_op != nil)
              op.addChild(next_op)
            end
		   else
			      return nil
       end
      return op
    end

    def assign()
        assgn = AST.new(Token.new("assignment","assignment"))
		if (@lookahead.type == Token::ID)
			idtok = AST.new(@lookahead)
			match(Token::ID)
			if (@lookahead.type == Token::ASSGN)
				assgn = AST.new(@lookahead)
				assgn.addChild(idtok)
            	match(Token::ASSGN)
        exp = exp()
				assgn.addChild(exp)
        	else
				match(Token::ASSGN)
			end
		else
			match(Token::ID)
        end
		return assgn
	end
end
