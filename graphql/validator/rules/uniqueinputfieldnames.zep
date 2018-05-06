namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\ObjectFieldNode;
use GraphQL\Language\Visitor;
use GraphQL\Validator\ValidationContext;
class UniqueInputFieldNames extends AbstractValidationRule
{
    static function duplicateInputFieldMessage(fieldName)
    {
        return "There can be only one input field named \"{fieldName}\".";
    }
    
    public knownNames;
    public knownNameStack;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray259de746c9d7816d6c58aa918e8a4ef7, fieldName, tmpArray1e3a91a1ffe95498dff48fb20c8f2323;
    
        let this->knownNames =  [];
        let this->knownNameStack =  [];
        let this->knownNameStack[] = this->knownNames;
        let this->knownNames =  [];
        let this->knownNames =  array_pop(this->knownNameStack);
        let fieldName =  node->name->value;
        let this->knownNames[fieldName] = node->name;
        let tmpArray259de746c9d7816d6c58aa918e8a4ef7 = let this->knownNameStack[] = this->knownNames;
        let this->knownNames =  [];
        let this->knownNames =  array_pop(this->knownNameStack);
        let fieldName =  node->name->value;
        let this->knownNames[fieldName] = node->name;
        [NodeKind::OBJECT : ["enter" : new UniqueInputFieldNamesgetVisitorClosureOne(), "leave" : new UniqueInputFieldNamesgetVisitorClosureOne()], NodeKind::OBJECT_FIELD : new UniqueInputFieldNamesgetVisitorClosureOne(context)];
        return tmpArraydfccee378163258f32044d13fe752d23;
    }

}