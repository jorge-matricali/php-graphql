namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\VariableDefinitionNode;
use GraphQL\Language\Printer;
use GraphQL\Type\Definition\InputType;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\TypeInfo;
use GraphQL\Validator\ValidationContext;
class VariablesAreInputTypes extends AbstractValidationRule
{
    static function nonInputTypeOnVarMessage(variableName, typeName)
    {
        return "Variable \"\${variableName}\" cannot be non-input type \"{typeName}\".";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArraya1af097b56dc0a10f2cb5d53c2462aea, type, variableName, tmpArraycd60ea4d89f7ac32b8abaabeda8c7c28;
    
        let type =  TypeInfo::typeFromAST(context->getSchema(), node->type);
        let variableName =  node->variable->name->value;
        let tmpArraya1af097b56dc0a10f2cb5d53c2462aea = let type =  TypeInfo::typeFromAST(context->getSchema(), node->type);
        let variableName =  node->variable->name->value;
        [NodeKind::VARIABLE_DEFINITION : new VariablesAreInputTypesgetVisitorClosureOne(context)];
        return tmpArray1d4867ca5039e54dc7b45db6856a0f8e;
    }

}