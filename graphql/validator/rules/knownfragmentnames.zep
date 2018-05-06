namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Validator\ValidationContext;
class KnownFragmentNames extends AbstractValidationRule
{
    static function unknownFragmentMessage(fragName)
    {
        return "Unknown fragment \"{fragName}\".";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray18a33f0bb4f2ed711d96b906f0e285f7, fragmentName, fragment, tmpArray736f969874be1338c842a5c3cca7dbf4;
    
        let fragmentName =  node->name->value;
        let fragment =  context->getFragment(fragmentName);
        let tmpArray18a33f0bb4f2ed711d96b906f0e285f7 = let fragmentName =  node->name->value;
        let fragment =  context->getFragment(fragmentName);
        [NodeKind::FRAGMENT_SPREAD : new KnownFragmentNamesgetVisitorClosureOne(context)];
        return tmpArraya4be3ed9ff45f288b2e0d60583990a8a;
    }

}