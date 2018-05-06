namespace GraphQL\Language;

use GraphQL\Language\AST\ArgumentNode;
use GraphQL\Language\AST\DirectiveDefinitionNode;
use GraphQL\Language\AST\EnumTypeDefinitionNode;
use GraphQL\Language\AST\EnumTypeExtensionNode;
use GraphQL\Language\AST\EnumValueDefinitionNode;
use GraphQL\Language\AST\FieldDefinitionNode;
use GraphQL\Language\AST\InputObjectTypeDefinitionNode;
use GraphQL\Language\AST\InputObjectTypeExtensionNode;
use GraphQL\Language\AST\InputValueDefinitionNode;
use GraphQL\Language\AST\InterfaceTypeDefinitionNode;
use GraphQL\Language\AST\InterfaceTypeExtensionNode;
use GraphQL\Language\AST\ListValueNode;
use GraphQL\Language\AST\BooleanValueNode;
use GraphQL\Language\AST\DirectiveNode;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\AST\EnumValueNode;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\FloatValueNode;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\InlineFragmentNode;
use GraphQL\Language\AST\IntValueNode;
use GraphQL\Language\AST\ListTypeNode;
use GraphQL\Language\AST\NamedTypeNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\NonNullTypeNode;
use GraphQL\Language\AST\NullValueNode;
use GraphQL\Language\AST\ObjectFieldNode;
use GraphQL\Language\AST\ObjectTypeDefinitionNode;
use GraphQL\Language\AST\ObjectValueNode;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\AST\OperationTypeDefinitionNode;
use GraphQL\Language\AST\ScalarTypeDefinitionNode;
use GraphQL\Language\AST\ScalarTypeExtensionNode;
use GraphQL\Language\AST\SchemaDefinitionNode;
use GraphQL\Language\AST\SelectionSetNode;
use GraphQL\Language\AST\StringValueNode;
use GraphQL\Language\AST\ObjectTypeExtensionNode;
use GraphQL\Language\AST\UnionTypeDefinitionNode;
use GraphQL\Language\AST\UnionTypeExtensionNode;
use GraphQL\Language\AST\VariableDefinitionNode;
use GraphQL\Utils\Utils;
/**
 * Prints AST to string. Capable of printing GraphQL queries and Type definition language.
 * Useful for pretty-printing queries or printing back AST for logging, documentation, etc.
 *
 * Usage example:
 *
 * ```php
 * $query = 'query myQuery {someField}';
 * $ast = GraphQL\Language\Parser::parse($query);
 * $printed = GraphQL\Language\Printer::doPrint($ast);
 * ```
 */
class Printer
{
    /**
     * Prints AST to string. Capable of printing GraphQL queries and Type definition language.
     *
     * @api
     * @param Node $ast
     * @return string
     */
    public static function doPrint(<Node> ast) -> string
    {
        var instance;
    
        
        let instance =  instance ? instance : new static();
        return instance->printAST(ast);
    }
    
    protected function __construct() -> void
    {
    }
    
    public function printAST(ast)
    {
        var tmpArray630f290ea978265eaf7f4c1bd34a7201, op, name, varDefs, directives, selectionSet, tmpArrayfc43800f1785c49f7838ed0c2f6003c5, tmpArray8be4d697d279bb36f8f7641e2424a482, tmpArray98ce4237463942135dd5792a4803d37c, tmpArray842c86a012de1132f1a29f32808b2183, tmpArray933e01cac4724704973c68c51ed4c1ae, tmpArray4c24772423feb11e03245b8833684272, tmpArraybfe31bf2e5796b0ae30ececb5ebe2fe1, tmpArraya42cf22b19dd8e22fe686e492f818ef6, tmpArray194a09c9531413a02c22f301167d84c9, tmpArray0ed6311a2b78c1ff87a24339f2346418, tmpArray94b5c1a599639a969fcfaa64a3ed263e, tmpArray7a6ccbade8adbf335921ec14b3304659, tmpArrayce9ecd41eed07a32c54295a96538c433, tmpArraya2cdad6ca9954efa18d98610108f7c18, tmpArray91122514ee7e98eb43a101fea3f6bbb5, tmpArray88dcd6cffb74c50084914d4d1f90fe02, tmpArraycfa09ce81961b69689cf1e44e7c8011e, tmpArraya199401c11907254e5e1af9c6042c0a5, tmpArray7742bde1be7a2867fefeed84a0c6f48c, tmpArray2ca7410fc7716622598724f8e37c700a, tmpArraye71ff515b6229043036eabf6e94462b0, tmpArray391d4d3348772fab3993affd814642be, tmpArraya8be20b0aaf330d2d6ab87a3724f8b0b, tmpArrayad7511cfa6fc99c93b9eb36f2e9e508e, tmpArray5ee573c97a7b0c0960c0643bcadbd44c, tmpArray751c404381a1581fb1f3e1fe9cfcc7d4, tmpArraya33810d76ba2211b696c2542eb2700f1, tmpArrayc0c45bb147efd797abf9f21805135ebb, tmpArray5237d9e4d4629ef1cfcf86ef29b2de51;
    
        let tmpArray630f290ea978265eaf7f4c1bd34a7201 = let op =  node->operation;
        let name =  node->name;
        let varDefs =  this->wrap("(", this->join(node->variableDefinitions, ", "), ")");
        let directives =  this->join(node->directives, " ");
        let selectionSet =  node->selectionSet;
        ["leave" : [NodeKind::NAME : new PrinterprintASTClosureOne(), NodeKind::VARIABLE : new PrinterprintASTClosureOne(), NodeKind::DOCUMENT : new PrinterprintASTClosureOne(), NodeKind::OPERATION_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::VARIABLE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::SELECTION_SET : new PrinterprintASTClosureOne(), NodeKind::FIELD : new PrinterprintASTClosureOne(), NodeKind::ARGUMENT : new PrinterprintASTClosureOne(), NodeKind::FRAGMENT_SPREAD : new PrinterprintASTClosureOne(), NodeKind::INLINE_FRAGMENT : new PrinterprintASTClosureOne(), NodeKind::FRAGMENT_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::INT : new PrinterprintASTClosureOne(), NodeKind::FLOAT : new PrinterprintASTClosureOne(), NodeKind::STRING : new PrinterprintASTClosureOne(), NodeKind::BOOLEAN : new PrinterprintASTClosureOne(), NodeKind::NULL : new PrinterprintASTClosureOne(), NodeKind::ENUM : new PrinterprintASTClosureOne(), NodeKind::LST : new PrinterprintASTClosureOne(), NodeKind::OBJECT : new PrinterprintASTClosureOne(), NodeKind::OBJECT_FIELD : new PrinterprintASTClosureOne(), NodeKind::DIRECTIVE : new PrinterprintASTClosureOne(), NodeKind::NAMED_TYPE : new PrinterprintASTClosureOne(), NodeKind::LIST_TYPE : new PrinterprintASTClosureOne(), NodeKind::NON_NULL_TYPE : new PrinterprintASTClosureOne(), NodeKind::SCHEMA_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::OPERATION_TYPE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::SCALAR_TYPE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::OBJECT_TYPE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::FIELD_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::INPUT_VALUE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::INTERFACE_TYPE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::UNION_TYPE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::ENUM_TYPE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::ENUM_VALUE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::INPUT_OBJECT_TYPE_DEFINITION : new PrinterprintASTClosureOne(), NodeKind::SCALAR_TYPE_EXTENSION : new PrinterprintASTClosureOne(), NodeKind::OBJECT_TYPE_EXTENSION : new PrinterprintASTClosureOne(), NodeKind::INTERFACE_TYPE_EXTENSION : new PrinterprintASTClosureOne(), NodeKind::UNION_TYPE_EXTENSION : new PrinterprintASTClosureOne(), NodeKind::ENUM_TYPE_EXTENSION : new PrinterprintASTClosureOne(), NodeKind::INPUT_OBJECT_TYPE_EXTENSION : new PrinterprintASTClosureOne(), NodeKind::DIRECTIVE_DEFINITION : new PrinterprintASTClosureOne()]];
        let op =  node->operation;
        let name =  node->name;
        let varDefs =  this->wrap("(", this->join(node->variableDefinitions, ", "), ")");
        let directives =  this->join(node->directives, " ");
        let selectionSet =  node->selectionSet;
        return Visitor::visit(ast, tmpArray54c2057476d8fd51b9e9729e1694f361);
    }
    
    /**
     * If maybeString is not null or empty, then wrap with start and end, otherwise
     * print an empty string.
     */
    public function wrap(start, maybeString, end = "")
    {
        return  maybeString ? start . maybeString . end  : "";
    }
    
    /**
     * Given array, print each item on its own line, wrapped in an
     * indented "{ }" block.
     */
    public function block(myArray)
    {
        return  myArray && this->length(myArray) ? "{
" . this->indent(this->join(myArray, "
")) . "
}"  : "";
    }
    
    public function indent(maybeString)
    {
        return  maybeString ? "  " . str_replace("
", "
  ", maybeString)  : "";
    }
    
    public function manyList(start, list, separator, end)
    {
        return  this->length(list) === 0 ? null  : start . this->join(list, separator) . end;
    }
    
    public function length(maybeArray)
    {
        return  maybeArray ? count(maybeArray)  : 0;
    }
    
    public function join(maybeArray, separator = "")
    {
        return  maybeArray ? implode(separator, Utils::filter(maybeArray, new PrinterjoinClosureOne()))  : "";
    }
    
    /**
     * Print a block string in the indented block form by adding a leading and
     * trailing blank line. However, if a block string starts with whitespace and is
     * a single-line, adding a leading blank line would strip that whitespace.
     */
    protected function printBlockString(value, isDescription)
    {
        var escaped;
    
        let escaped =  str_replace("\"\"\"", "\\\"\"\"", value);
        return  (value[0] === " " || value[0] === "	") && strpos(value, "
") === false ? "\"\"\"" . preg_replace("/\"$/", "\"
", escaped) . "\"\"\""  : "\"\"\"
" . ( isDescription ? escaped  : this->indent(escaped)) . "
\"\"\"";
    }

}