namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\AST\VariableDefinitionNode;
use GraphQL\Type\Definition\ListOfType;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Utils\TypeComparators;
use GraphQL\Utils\TypeInfo;
use GraphQL\Validator\ValidationContext;
class VariablesInAllowedPosition extends AbstractValidationRule
{
    static function badVarPosMessage(varName, varType, expectedType)
    {
        return "Variable \"\${varName}\" of type \"{varType}\" used in position expecting " . "type \"{expectedType}\".";
    }
    
    public varDefMap;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArrayb8f5dadbed641aa52af457bfe87197b6, usages, usage, node, type, varName, varDef, schema, varType, tmpArray742b16e2d496c4ee2a15b4190b952035;
    
        let this->varDefMap =  [];
        let usages =  context->getRecursiveVariableUsages(operation);
        let node = usage["node"];
        let type = usage["type"];
        let varName =  node->name->value;
        let varDef =  isset this->varDefMap[varName] ? this->varDefMap[varName]  : null;
        let schema =  context->getSchema();
        let varType =  TypeInfo::typeFromAST(schema, varDef->type);
        let this->varDefMap[varDefNode->variable->name->value] = varDefNode;
        let tmpArrayb8f5dadbed641aa52af457bfe87197b6 = let this->varDefMap =  [];
        let usages =  context->getRecursiveVariableUsages(operation);
        let node = usage["node"];
        let type = usage["type"];
        let varName =  node->name->value;
        let varDef =  isset this->varDefMap[varName] ? this->varDefMap[varName]  : null;
        let schema =  context->getSchema();
        let varType =  TypeInfo::typeFromAST(schema, varDef->type);
        let this->varDefMap[varDefNode->variable->name->value] = varDefNode;
        [NodeKind::OPERATION_DEFINITION : ["enter" : new VariablesInAllowedPositiongetVisitorClosureOne(), "leave" : new VariablesInAllowedPositiongetVisitorClosureOne(context)], NodeKind::VARIABLE_DEFINITION : new VariablesInAllowedPositiongetVisitorClosureOne()];
        return tmpArray1bbc167fd5b14211a098ac3379abb12b;
    }
    
    // A var type is allowed if it is the same or more strict than the expected
    // type. It can be more strict if the variable type is non-null when the
    // expected type is nullable. If both are list types, the variable item type can
    // be more strict than the expected item type.
    protected function varTypeAllowedForType(varType, expectedType)
    {
        if expectedType instanceof NonNull {
            if varType instanceof NonNull {
                return this->varTypeAllowedForType(varType->getWrappedType(), expectedType->getWrappedType());
            }
            return false;
        }
        if varType instanceof NonNull {
            return this->varTypeAllowedForType(varType->getWrappedType(), expectedType);
        }
        if varType instanceof ListOfType && expectedType instanceof ListOfType {
            return this->varTypeAllowedForType(varType->getWrappedType(), expectedType->getWrappedType());
        }
        return varType === expectedType;
    }
    
    // If a variable definition has a default value, it's effectively non-null.
    protected function effectiveType(varType, varDef)
    {
        return  !(varDef->defaultValue) || varType instanceof NonNull ? varType  : new NonNull(varType);
    }

}