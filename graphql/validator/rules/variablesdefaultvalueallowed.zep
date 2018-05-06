namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\SelectionSetNode;
use GraphQL\Language\AST\VariableDefinitionNode;
use GraphQL\Language\Visitor;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Validator\ValidationContext;
/**
 * Variable's default value is allowed
 *
 * A GraphQL document is only valid if all variable default values are allowed
 * due to a variable not being required.
 */
class VariablesDefaultValueAllowed extends AbstractValidationRule
{
    static function defaultForRequiredVarMessage(varName, type, guessType)
    {
        return "Variable \"\${varName}\" of type \"{type}\" is required and " . "will not use the default value. " . "Perhaps you meant to use type \"{guessType}\".";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray80f25d289bd0102669eaad7045d60f61, name, defaultValue, type, tmpArray3c8ca29318448e23a2c053003526313e;
    
        let name =  node->variable->name->value;
        let defaultValue =  node->defaultValue;
        let type =  context->getInputType();
        let tmpArray80f25d289bd0102669eaad7045d60f61 = let name =  node->variable->name->value;
        let defaultValue =  node->defaultValue;
        let type =  context->getInputType();
        [NodeKind::VARIABLE_DEFINITION : new VariablesDefaultValueAllowedgetVisitorClosureOne(context), NodeKind::SELECTION_SET : new VariablesDefaultValueAllowedgetVisitorClosureOne(context), NodeKind::FRAGMENT_DEFINITION : new VariablesDefaultValueAllowedgetVisitorClosureOne(context)];
        return tmpArray0694e30e415cc162cd8153e10999eba0;
    }

}