Start
  = Program

Program
  = _ declarations:Declaration* _ { return declarations; }

Declaration
  = ProviderDeclaration
  / ResourceDeclaration

ProviderDeclaration
  = "provider" _ name:StringLiteral _ block:Block {
    return {
      type: "provider",
      name: name,
      block: block,
      location: location()
    };
  }

ResourceDeclaration
  = "resource" _ type:StringLiteral _ name:StringLiteral _ block:Block {
    return {
      type: "resource",
      resourceType: type,
      name: name,
      block: block,
      location: location()
    };
  }

Block
  = "do" _ statements:Statement* _ "end" {
    return {
      type: "block",
      body: statements,
      location: location()
    };
  }

Statement
  = Assignment
  / Block

Assignment
  = key:Identifier _ value:Value {
    return {
      type: "assignment",
      key: key,
      value: value,
      location: location()
    };
  }

Value
  = StringLiteral
  / NumberLiteral
  / Block

StringLiteral
  = '"' chars:[^"]* '"' { return chars.join(''); }

NumberLiteral
  = digits:[0-9]+ { return parseInt(digits.join(''), 10); }

Identifier
  = chars:[a-zA-Z_][a-zA-Z0-9_]* { return chars.join(''); }

_ "whitespace"
  = [ \t\n\r]*
