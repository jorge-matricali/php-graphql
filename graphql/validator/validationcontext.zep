namespace GraphQL\Validator;

use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\HasSelectionSet;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\AST\VariableNode;
use GraphQL\Language\Visitor;
use SplObjectStorage;
use GraphQL\Error\Error;
use GraphQL\Type\Schema;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Type\Definition\CompositeType;
use GraphQL\Type\Definition\FieldDefinition;
use GraphQL\Type\Definition\InputType;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\TypeInfo;
/**
 * An instance of this class is passed as the "this" context to all validators,
 * allowing access to commonly useful contextual information from within a
 * validation rule.
 */
class ValidationContext
{
    /**
     * @var Schema
     */
    protected schema;
    /**
     * @var DocumentNode
     */
    protected ast;
    /**
     * @var TypeInfo
     */
    protected typeInfo;
    /**
     * @var Error[]
     */
    protected errors;
    /**
     * @var FragmentDefinitionNode[]
     */
    protected fragments;
    /**
     * @var SplObjectStorage
     */
    protected fragmentSpreads;
    /**
     * @var SplObjectStorage
     */
    protected recursivelyReferencedFragments;
    /**
     * @var SplObjectStorage
     */
    protected variableUsages;
    /**
     * @var SplObjectStorage
     */
    protected recursiveVariableUsages;
    /**
     * ValidationContext constructor.
     *
     * @param Schema $schema
     * @param DocumentNode $ast
     * @param TypeInfo $typeInfo
     */
    function __construct(<Schema> schema, <DocumentNode> ast, <TypeInfo> typeInfo) -> void
    {
        let this->schema = schema;
        let this->ast = ast;
        let this->typeInfo = typeInfo;
        let this->errors =  [];
        let this->fragmentSpreads =  new SplObjectStorage();
        let this->recursivelyReferencedFragments =  new SplObjectStorage();
        let this->variableUsages =  new SplObjectStorage();
        let this->recursiveVariableUsages =  new SplObjectStorage();
    }
    
    /**
     * @param Error $error
     */
    function reportError(<Error> error) -> void
    {
        let this->errors[] = error;
    }
    
    /**
     * @return Error[]
     */
    function getErrors() -> array
    {
        return this->errors;
    }
    
    /**
     * @return Schema
     */
    function getSchema() -> <Schema>
    {
        return this->schema;
    }
    
    /**
     * @return DocumentNode
     */
    function getDocument() -> <DocumentNode>
    {
        return this->ast;
    }
    
    /**
     * @param string $name
     * @return FragmentDefinitionNode|null
     */
    function getFragment(string name)
    {
        var fragments, statement;
    
        let fragments =  this->fragments;
        if !(fragments) {
            let fragments =  [];
            for statement in this->getDocument()->definitions {
                if statement->kind === NodeKind::FRAGMENT_DEFINITION {
                    let fragments[statement->name->value] = statement;
                }
            }
            let this->fragments = fragments;
        }
        return  isset fragments[name] ? fragments[name]  : null;
    }
    
    /**
     * @param HasSelectionSet $node
     * @return FragmentSpreadNode[]
     */
    function getFragmentSpreads(<HasSelectionSet> node) -> array
    {
        var spreads, setsToVisit, set, i, selection;
    
        let spreads =  isset this->fragmentSpreads[node] ? this->fragmentSpreads[node]  : null;
        if !(spreads) {
            let spreads =  [];
            let setsToVisit =  [node->selectionSet];
            while (!(empty(setsToVisit))) {
                let set =  array_pop(setsToVisit);
                let i = 0;
                for i in range(0, count(set->selections)) {
                    let selection = set->selections[i];
                    if selection->kind === NodeKind::FRAGMENT_SPREAD {
                        let spreads[] = selection;
                    } else {
                        if selection->selectionSet {
                            let setsToVisit[] = selection->selectionSet;
                        }
                    }
                }
            }
            let this->fragmentSpreads[node] = spreads;
        }
        return spreads;
    }
    
    /**
     * @param OperationDefinitionNode $operation
     * @return FragmentDefinitionNode[]
     */
    function getRecursivelyReferencedFragments(<OperationDefinitionNode> operation) -> array
    {
        var fragments, collectedNames, nodesToVisit, node, spreads, i, fragName, fragment;
    
        let fragments =  isset this->recursivelyReferencedFragments[operation] ? this->recursivelyReferencedFragments[operation]  : null;
        if !(fragments) {
            let fragments =  [];
            let collectedNames =  [];
            let nodesToVisit =  [operation];
            while (!(empty(nodesToVisit))) {
                let node =  array_pop(nodesToVisit);
                let spreads =  this->getFragmentSpreads(node);
                let i = 0;
                for i in range(0, count(spreads)) {
                    let fragName =  spreads[i]->name->value;
                    if empty(collectedNames[fragName]) {
                        let collectedNames[fragName] = true;
                        let fragment =  this->getFragment(fragName);
                        if fragment {
                            let fragments[] = fragment;
                            let nodesToVisit[] = fragment;
                        }
                    }
                }
            }
            let this->recursivelyReferencedFragments[operation] = fragments;
        }
        return fragments;
    }
    
    /**
     * @param HasSelectionSet $node
     * @return array List of ['node' => VariableNode, 'type' => ?InputObjectType]
     */
    function getVariableUsages(<HasSelectionSet> node) -> array
    {
        var usages, newUsages, typeInfo, tmpArraycfd347fd6908b8e575aca73cfddaa417;
    
        let usages =  isset this->variableUsages[node] ? this->variableUsages[node]  : null;
        if !(usages) {
            let newUsages =  [];
            let typeInfo =  new TypeInfo(this->schema);
            Visitor::visit(node, Visitor::visitWithTypeInfo(typeInfo, let newUsages[] =  ["node" : variable, "type" : typeInfo->getInputType()];
            [NodeKind::VARIABLE_DEFINITION : new ValidationContextgetVariableUsagesClosureOne(), NodeKind::VARIABLE : new ValidationContextgetVariableUsagesClosureOne(newUsages, typeInfo)]));
            let usages = newUsages;
            let this->variableUsages[node] = usages;
        }
        return usages;
    }
    
    /**
     * @param OperationDefinitionNode $operation
     * @return array List of ['node' => VariableNode, 'type' => ?InputObjectType]
     */
    function getRecursiveVariableUsages(<OperationDefinitionNode> operation) -> array
    {
        var usages, fragments, tmp, i;
    
        let usages =  isset this->recursiveVariableUsages[operation] ? this->recursiveVariableUsages[operation]  : null;
        if !(usages) {
            let usages =  this->getVariableUsages(operation);
            let fragments =  this->getRecursivelyReferencedFragments(operation);
            let tmp =  [usages];
            let i = 0;
            for i in range(0, count(fragments)) {
                let tmp[] =  this->getVariableUsages(fragments[i]);
            }
            let usages =  call_user_func_array("array_merge", tmp);
            let this->recursiveVariableUsages[operation] = usages;
        }
        return usages;
    }
    
    /**
     * Returns OutputType
     *
     * @return Type
     */
    function getType() -> <Type>
    {
        return this->typeInfo->getType();
    }
    
    /**
     * @return CompositeType
     */
    function getParentType() -> <CompositeType>
    {
        return this->typeInfo->getParentType();
    }
    
    /**
     * @return InputType
     */
    function getInputType() -> <InputType>
    {
        return this->typeInfo->getInputType();
    }
    
    /**
     * @return InputType
     */
    function getParentInputType() -> <InputType>
    {
        return this->typeInfo->getParentInputType();
    }
    
    /**
     * @return FieldDefinition
     */
    function getFieldDef() -> <FieldDefinition>
    {
        return this->typeInfo->getFieldDef();
    }
    
    function getDirective()
    {
        return this->typeInfo->getDirective();
    }
    
    function getArgument()
    {
        return this->typeInfo->getArgument();
    }

}