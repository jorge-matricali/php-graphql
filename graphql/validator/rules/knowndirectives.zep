namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\DirectiveNode;
use GraphQL\Language\AST\InputObjectTypeDefinitionNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\DirectiveLocation;
use GraphQL\Validator\ValidationContext;
class KnownDirectives extends AbstractValidationRule
{
    static function unknownDirectiveMessage(directiveName)
    {
        return "Unknown directive \"{directiveName}\".";
    }
    
    static function misplacedDirectiveMessage(directiveName, location)
    {
        return "Directive \"{directiveName}\" may not be used on \"{location}\".";
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray4d4bb131a50bf53955414e21c017c1c4, directiveDef, def, tmpArray9178e7633cda8fe66362c1060dfa3bd2, candidateLocation, tmpArray8f1c5ac16e5368b238f94e690f6edfcd, tmpArrayf83e9f889c4657440fbaa6639a177308;
    
        let directiveDef =  null;
        let directiveDef = def;
        let candidateLocation =  this->getDirectiveLocationForASTPath(ancestors);
        let tmpArray4d4bb131a50bf53955414e21c017c1c4 = let directiveDef =  null;
        let directiveDef = def;
        let candidateLocation =  this->getDirectiveLocationForASTPath(ancestors);
        [NodeKind::DIRECTIVE : new KnownDirectivesgetVisitorClosureOne(context)];
        return tmpArray66b3cc4a4828a87a29e3c2bd3568de45;
    }
    
    protected function getDirectiveLocationForASTPath(array ancestors)
    {
        var appliedTo, parentNode;
    
        let appliedTo = ancestors[count(ancestors) - 1];
        if NodeKind::OPERATION_DEFINITION {
            switch (appliedTo->operation) {
                case "query":
                    return DirectiveLocation::QUERY;
                case "mutation":
                    return DirectiveLocation::MUTATION;
                case "subscription":
                    return DirectiveLocation::SUBSCRIPTION;
            }
        } elseif NodeKind::INPUT_OBJECT_TYPE_DEFINITION || NodeKind::INPUT_OBJECT_TYPE_EXTENSION {
            return DirectiveLocation::INPUT_OBJECT;
        } elseif NodeKind::ENUM_VALUE_DEFINITION {
            return DirectiveLocation::ENUM_VALUE;
        } elseif NodeKind::ENUM_TYPE_DEFINITION || NodeKind::ENUM_TYPE_EXTENSION {
            return DirectiveLocation::ENUM;
        } elseif NodeKind::UNION_TYPE_DEFINITION || NodeKind::UNION_TYPE_EXTENSION {
            return DirectiveLocation::UNION;
        } elseif NodeKind::INTERFACE_TYPE_DEFINITION || NodeKind::INTERFACE_TYPE_EXTENSION {
            return DirectiveLocation::IFACE;
        } elseif NodeKind::FIELD_DEFINITION {
            return DirectiveLocation::FIELD_DEFINITION;
        } elseif NodeKind::OBJECT_TYPE_DEFINITION || NodeKind::OBJECT_TYPE_EXTENSION {
            return DirectiveLocation::OBJECT;
        } elseif NodeKind::SCALAR_TYPE_DEFINITION || NodeKind::SCALAR_TYPE_EXTENSION {
            return DirectiveLocation::SCALAR;
        } elseif NodeKind::SCHEMA_DEFINITION {
            return DirectiveLocation::SCHEMA;
        } elseif NodeKind::FRAGMENT_DEFINITION {
            return DirectiveLocation::FRAGMENT_DEFINITION;
        } elseif NodeKind::INLINE_FRAGMENT {
            return DirectiveLocation::INLINE_FRAGMENT;
        } elseif NodeKind::FRAGMENT_SPREAD {
            return DirectiveLocation::FRAGMENT_SPREAD;
        } elseif NodeKind::FIELD {
            return DirectiveLocation::FIELD;
        } else {
            let parentNode = ancestors[count(ancestors) - 3];
            return  parentNode instanceof InputObjectTypeDefinitionNode ? DirectiveLocation::INPUT_FIELD_DEFINITION  : DirectiveLocation::ARGUMENT_DEFINITION;
        }
    }

}