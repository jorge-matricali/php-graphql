namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\Visitor;
use GraphQL\Validator\ValidationContext;
/**
 * Executable definitions
 *
 * A GraphQL document is only valid for execution if all definitions are either
 * operation or fragment definitions.
 */
class ExecutableDefinitions extends AbstractValidationRule
{
    static function nonExecutableDefinitionMessage(defName)
    {
        return "The \"{defName}\" definition is not executable.";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray56093b8c28cbd18ee5b233639c58449e, definition, tmpArray3498d540d01b4bce39100dd39ddb756c;
    
        let tmpArray56093b8c28cbd18ee5b233639c58449e = [NodeKind::DOCUMENT : new ExecutableDefinitionsgetVisitorClosureOne(context)];
        return tmpArray9d62461e6e423afc789bfc563b861a65;
    }

}