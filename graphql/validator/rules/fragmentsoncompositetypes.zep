namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\InlineFragmentNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\Printer;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\TypeInfo;
use GraphQL\Validator\ValidationContext;
class FragmentsOnCompositeTypes extends AbstractValidationRule
{
    static function inlineFragmentOnNonCompositeErrorMessage(type)
    {
        return "Fragment cannot condition on non composite type \"{type}\".";
    }
    
    static function fragmentOnNonCompositeErrorMessage(fragName, type)
    {
        return "Fragment \"{fragName}\" cannot condition on non composite type \"{type}\".";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray6d57cb2c750b89b1496c9b5687769906, type, tmpArray40e284e57b4fc0f91f90a6badd02b216, tmpArrayc285a6b8a33654f811120b5b96427ab8;
    
        let type =  TypeInfo::typeFromAST(context->getSchema(), node->typeCondition);
        let type =  TypeInfo::typeFromAST(context->getSchema(), node->typeCondition);
        let tmpArray6d57cb2c750b89b1496c9b5687769906 = let type =  TypeInfo::typeFromAST(context->getSchema(), node->typeCondition);
        let type =  TypeInfo::typeFromAST(context->getSchema(), node->typeCondition);
        [NodeKind::INLINE_FRAGMENT : new FragmentsOnCompositeTypesgetVisitorClosureOne(context), NodeKind::FRAGMENT_DEFINITION : new FragmentsOnCompositeTypesgetVisitorClosureOne(context)];
        return tmpArrayac60c1d652d0e1453c92d18feb50fba5;
    }

}