namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\InlineFragmentNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Type\Schema;
use GraphQL\Type\Definition\AbstractType;
use GraphQL\Type\Definition\CompositeType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\UnionType;
use GraphQL\Validator\ValidationContext;
use GraphQL\Utils\TypeInfo;
class PossibleFragmentSpreads extends AbstractValidationRule
{
    static function typeIncompatibleSpreadMessage(fragName, parentType, fragType)
    {
        return "Fragment \"{fragName}\" cannot be spread here as objects of type \"{parentType}\" can never be of type \"{fragType}\".";
    }
    
    static function typeIncompatibleAnonSpreadMessage(parentType, fragType)
    {
        return "Fragment cannot be spread here as objects of type \"{parentType}\" can never be of type \"{fragType}\".";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray1c031bb0bd89c2c88ce93d3638180664, fragType, parentType, tmpArray3beb4da4bda342a7fb978d6e83a7dc3c, fragName, tmpArrayde2b872a1ecdb579144769007f2df94c;
    
        let fragType =  context->getType();
        let parentType =  context->getParentType();
        let fragName =  node->name->value;
        let fragType =  this->getFragmentType(context, fragName);
        let parentType =  context->getParentType();
        let tmpArray1c031bb0bd89c2c88ce93d3638180664 = let fragType =  context->getType();
        let parentType =  context->getParentType();
        let fragName =  node->name->value;
        let fragType =  this->getFragmentType(context, fragName);
        let parentType =  context->getParentType();
        [NodeKind::INLINE_FRAGMENT : new PossibleFragmentSpreadsgetVisitorClosureOne(context), NodeKind::FRAGMENT_SPREAD : new PossibleFragmentSpreadsgetVisitorClosureOne(context)];
        return tmpArray29a07eb11dbfcf010fdb2e89f787f15c;
    }
    
    protected function getFragmentType(<ValidationContext> context, name)
    {
        var frag, type;
    
        let frag =  context->getFragment(name);
        if frag {
            let type =  TypeInfo::typeFromAST(context->getSchema(), frag->typeCondition);
            if type instanceof CompositeType {
                return type;
            }
        }
        return null;
    }
    
    protected function doTypesOverlap(<Schema> schema, <CompositeType> fragType, <CompositeType> parentType)
    {
        var type;
    
        // Checking in the order of the most frequently used scenarios:
        // Parent type === fragment type
        if parentType === fragType {
            return true;
        }
        // Parent type is interface or union, fragment type is object type
        if parentType instanceof AbstractType && fragType instanceof ObjectType {
            return schema->isPossibleType(parentType, fragType);
        }
        // Parent type is object type, fragment type is interface (or rather rare - union)
        if parentType instanceof ObjectType && fragType instanceof AbstractType {
            return schema->isPossibleType(fragType, parentType);
        }
        // Both are object types:
        if parentType instanceof ObjectType && fragType instanceof ObjectType {
            return parentType === fragType;
        }
        // Both are interfaces
        // This case may be assumed valid only when implementations of two interfaces intersect
        // But we don't have information about all implementations at runtime
        // (getting this information via $schema->getPossibleTypes() requires scanning through whole schema
        // which is very costly to do at each request due to PHP "shared nothing" architecture)
        //
        // So in this case we just make it pass - invalid fragment spreads will be simply ignored during execution
        // See also https://github.com/webonyx/graphql-php/issues/69#issuecomment-283954602
        if parentType instanceof InterfaceType && fragType instanceof InterfaceType {
            return true;
        }
        // Interface within union
        if parentType instanceof UnionType && fragType instanceof InterfaceType {
            for type in parentType->getTypes() {
                if type->implementsInterface(fragType) {
                    return true;
                }
            }
        }
        if parentType instanceof InterfaceType && fragType instanceof UnionType {
            for type in fragType->getTypes() {
                if type->implementsInterface(parentType) {
                    return true;
                }
            }
        }
        if parentType instanceof UnionType && fragType instanceof UnionType {
            for type in fragType->getTypes() {
                if parentType->isPossibleType(type) {
                    return true;
                }
            }
        }
        return false;
    }

}