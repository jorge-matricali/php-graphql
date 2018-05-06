namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\DirectiveNode;
use GraphQL\Language\AST\Node;
use GraphQL\Validator\ValidationContext;
class UniqueDirectivesPerLocation extends AbstractValidationRule
{
    static function duplicateDirectiveMessage(directiveName)
    {
        return "The directive \"" . directiveName . "\" can only be used once at this location.";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArraya18d59ecd37908d378afb6abdf30cc85, knownDirectives, directive, directiveName, tmpArray21963b1ad5f329b9214c8e74713414a1;
    
        let knownDirectives =  [];
        let directiveName =  directive->name->value;
        let knownDirectives[directiveName] = directive;
        let tmpArraya18d59ecd37908d378afb6abdf30cc85 = let knownDirectives =  [];
        let directiveName =  directive->name->value;
        let knownDirectives[directiveName] = directive;
        ["enter" : new UniqueDirectivesPerLocationgetVisitorClosureOne(context)];
        return tmpArray0c243e4bf4c09360db219a895a3bff22;
    }

}