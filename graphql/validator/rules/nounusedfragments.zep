namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\Visitor;
use GraphQL\Validator\ValidationContext;
class NoUnusedFragments extends AbstractValidationRule
{
    static function unusedFragMessage(fragName)
    {
        return "Fragment \"{fragName}\" is never used.";
    }
    
    public operationDefs;
    public fragmentDefs;
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray92737917862dc8095e0391fe90116de2, fragmentNameUsed, operation, fragment, fragmentDef, fragName, tmpArray028c5578e4322fe05979a3a4e3a7c543;
    
        let this->operationDefs =  [];
        let this->fragmentDefs =  [];
        let this->operationDefs[] = node;
        let this->fragmentDefs[] = def;
        let fragmentNameUsed =  [];
        let fragmentNameUsed[fragment->name->value] = true;
        let fragName =  fragmentDef->name->value;
        let tmpArray92737917862dc8095e0391fe90116de2 = let this->operationDefs[] = node;
        let this->fragmentDefs[] = def;
        let fragmentNameUsed =  [];
        let fragmentNameUsed[fragment->name->value] = true;
        let fragName =  fragmentDef->name->value;
        [NodeKind::OPERATION_DEFINITION : new NoUnusedFragmentsgetVisitorClosureOne(), NodeKind::FRAGMENT_DEFINITION : new NoUnusedFragmentsgetVisitorClosureOne(), NodeKind::DOCUMENT : ["leave" : new NoUnusedFragmentsgetVisitorClosureOne(context)]];
        return tmpArray334b38f2204fbfc1c576c15ad28962bd;
    }

}