namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Type\Definition\Type;
use GraphQL\Validator\ValidationContext;
class ScalarLeafs extends AbstractValidationRule
{
    static function noSubselectionAllowedMessage(field, type)
    {
        return "Field \"{field}\" of type \"{type}\" must not have a sub selection.";
    }
    
    static function requiredSubselectionMessage(field, type)
    {
        return "Field \"{field}\" of type \"{type}\" must have a sub selection.";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray8d6a1e8521ec0cf5e59ac2dc1d0b7317, type, tmpArrayaa452fe94b325efcbd7a9779dfd7f5c9, tmpArray9178e7633cda8fe66362c1060dfa3bd2;
    
        let type =  context->getType();
        let tmpArray8d6a1e8521ec0cf5e59ac2dc1d0b7317 = let type =  context->getType();
        [NodeKind::FIELD : new ScalarLeafsgetVisitorClosureOne(context)];
        return tmpArray73b21e7566183791830666f1a795444d;
    }

}