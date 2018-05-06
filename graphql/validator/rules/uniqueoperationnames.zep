namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\Visitor;
use GraphQL\Validator\ValidationContext;
class UniqueOperationNames extends AbstractValidationRule
{
    static function duplicateOperationNameMessage(operationName)
    {
        return "There can be only one operation named \"{operationName}\".";
    }
    
    public knownOperationNames;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray961de8848edfddcaeaa2bb3e7882970b, operationName, tmpArraye94e3b040d648cc60afca771fbcd100e;
    
        let this->knownOperationNames =  [];
        let operationName =  node->name;
        let this->knownOperationNames[operationName->value] = operationName;
        let tmpArray961de8848edfddcaeaa2bb3e7882970b = let operationName =  node->name;
        let this->knownOperationNames[operationName->value] = operationName;
        [NodeKind::OPERATION_DEFINITION : new UniqueOperationNamesgetVisitorClosureOne(context), NodeKind::FRAGMENT_DEFINITION : new UniqueOperationNamesgetVisitorClosureOne()];
        return tmpArray361dd7629dfc179f345ae091e3292d07;
    }

}