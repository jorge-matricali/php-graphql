namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\VariableDefinitionNode;
use GraphQL\Validator\ValidationContext;
class UniqueVariableNames extends AbstractValidationRule
{
    static function duplicateVariableMessage(variableName)
    {
        return "There can be only one variable named \"{variableName}\".";
    }
    
    public knownVariableNames;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray566e74f31aadcbb6f3a0d933c2704e19, variableName, tmpArray783494199014d40264f67a3633e00bc2;
    
        let this->knownVariableNames =  [];
        let this->knownVariableNames =  [];
        let variableName =  node->variable->name->value;
        let this->knownVariableNames[variableName] = node->variable->name;
        let tmpArray566e74f31aadcbb6f3a0d933c2704e19 = let this->knownVariableNames =  [];
        let variableName =  node->variable->name->value;
        let this->knownVariableNames[variableName] = node->variable->name;
        [NodeKind::OPERATION_DEFINITION : new UniqueVariableNamesgetVisitorClosureOne(), NodeKind::VARIABLE_DEFINITION : new UniqueVariableNamesgetVisitorClosureOne(context)];
        return tmpArray7075f3caebd2c84898be0b1a552f439a;
    }

}