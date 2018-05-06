namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\ArgumentNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\Visitor;
use GraphQL\Validator\ValidationContext;
class UniqueArgumentNames extends AbstractValidationRule
{
    static function duplicateArgMessage(argName)
    {
        return "There can be only one argument named \"{argName}\".";
    }
    
    public knownArgNames;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArrayf512a31ef7e74e34a72310feadc29434, argName, tmpArrayd7a06bf8662f3f7a34e872cc844ea36f;
    
        let this->knownArgNames =  [];
        let this->knownArgNames =  [];
        let this->knownArgNames =  [];
        let argName =  node->name->value;
        let this->knownArgNames[argName] = node->name;
        let tmpArrayf512a31ef7e74e34a72310feadc29434 = let this->knownArgNames =  [];
        let this->knownArgNames =  [];
        let argName =  node->name->value;
        let this->knownArgNames[argName] = node->name;
        [NodeKind::FIELD : new UniqueArgumentNamesgetVisitorClosureOne(), NodeKind::DIRECTIVE : new UniqueArgumentNamesgetVisitorClosureOne(), NodeKind::ARGUMENT : new UniqueArgumentNamesgetVisitorClosureOne(context)];
        return tmpArray03db906b2885b29ef8ff63791ec00650;
    }

}