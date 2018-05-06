namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Utils\Utils;
use GraphQL\Validator\ValidationContext;
/**
 * Lone anonymous operation
 *
 * A GraphQL document is only valid if when it contains an anonymous operation
 * (the query short-hand) that it contains only that one operation definition.
 */
class LoneAnonymousOperation extends AbstractValidationRule
{
    static function anonOperationNotAloneMessage()
    {
        return "This anonymous operation must be the only defined operation.";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var operationCount, tmpArraya25fd950463363f343666781880703ea, tmp, tmpArraybb2457d14c6e80e601b6f651060944a5;
    
        let operationCount = 0;
        let tmp =  Utils::filter(node->definitions, new LoneAnonymousOperationgetVisitorClosureOne());
        let operationCount =  count(tmp);
        let tmpArraya25fd950463363f343666781880703ea = let tmp =  Utils::filter(node->definitions, new LoneAnonymousOperationgetVisitorClosureOne());
        let operationCount =  count(tmp);
        [NodeKind::DOCUMENT : new LoneAnonymousOperationgetVisitorClosureOne(operationCount), NodeKind::OPERATION_DEFINITION : new LoneAnonymousOperationgetVisitorClosureOne(operationCount, context)];
        return tmpArray7f051a54c8c4169d548160f9be764a4e;
    }

}