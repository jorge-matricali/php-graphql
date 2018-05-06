namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\ArgumentNode;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\Visitor;
use GraphQL\Validator\ValidationContext;
class UniqueFragmentNames extends AbstractValidationRule
{
    static function duplicateFragmentNameMessage(fragName)
    {
        return "There can be only one fragment named \"{fragName}\".";
    }
    
    public knownFragmentNames;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArrayeef0a5daf93537ddd3dc6bde573a288a, fragmentName, tmpArraya7728949b19aefe00f2253a49d3942a8;
    
        let this->knownFragmentNames =  [];
        let fragmentName =  node->name->value;
        let this->knownFragmentNames[fragmentName] = node->name;
        let tmpArrayeef0a5daf93537ddd3dc6bde573a288a = let fragmentName =  node->name->value;
        let this->knownFragmentNames[fragmentName] = node->name;
        [NodeKind::OPERATION_DEFINITION : new UniqueFragmentNamesgetVisitorClosureOne(), NodeKind::FRAGMENT_DEFINITION : new UniqueFragmentNamesgetVisitorClosureOne(context)];
        return tmpArray707e3dedbc8a45ddd2872b3a99bed4e4;
    }

}