namespace GraphQL\Validator\Rules;

use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\FragmentDefinitionNode;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\InlineFragmentNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\SelectionSetNode;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Introspection;
use GraphQL\Utils\TypeInfo;
use GraphQL\Validator\ValidationContext;
abstract class AbstractQuerySecurity extends AbstractValidationRule
{
    const DISABLED = 0;
    /**
     * @var FragmentDefinitionNode[]
     */
    protected fragments = [];
    /**
     * @return \GraphQL\Language\AST\FragmentDefinitionNode[]
     */
    protected function getFragments() -> array
    {
        return this->fragments;
    }
    
    /**
     * check if equal to 0 no check is done. Must be greater or equal to 0.
     *
     * @param $value
     */
    protected function checkIfGreaterOrEqualToZero(name, value) -> void
    {
        if value < 0 {
            throw new \InvalidArgumentException(sprintf("$%s argument must be greater or equal to 0.", name));
        }
    }
    
    protected function gatherFragmentDefinition(<ValidationContext> context) -> void
    {
        var definitions, node;
    
        // Gather all the fragment definition.
        // Importantly this does not include inline fragments.
        let definitions =  context->getDocument()->definitions;
        for node in definitions {
            if node instanceof FragmentDefinitionNode {
                let this->fragments[node->name->value] = node;
            }
        }
    }
    
    protected function getFragment(<FragmentSpreadNode> fragmentSpread)
    {
        var spreadName, fragments;
    
        let spreadName =  fragmentSpread->name->value;
        let fragments =  this->getFragments();
        return  isset fragments[spreadName] ? fragments[spreadName]  : null;
    }
    
    protected function invokeIfNeeded(<ValidationContext> context, array validators)
    {
        var tmpArray40cd750bba9870f18aada2478b24840a;
    
        // is disabled?
        if !(this->isEnabled()) {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return tmpArray40cd750bba9870f18aada2478b24840a;
        }
        this->gatherFragmentDefinition(context);
        return validators;
    }
    
    /**
     * Given a selectionSet, adds all of the fields in that selection to
     * the passed in map of fields, and returns it at the end.
     *
     * Note: This is not the same as execution's collectFields because at static
     * time we do not know what object type will be used, so we unconditionally
     * spread in all fragments.
     *
     * @see \GraphQL\Validator\Rules\OverlappingFieldsCanBeMerged
     *
     * @param ValidationContext $context
     * @param Type|null         $parentType
     * @param SelectionSetNode      $selectionSet
     * @param \ArrayObject      $visitedFragmentNames
     * @param \ArrayObject      $astAndDefs
     *
     * @return \ArrayObject
     */
    protected function collectFieldASTsAndDefs(<ValidationContext> context, parentType, <SelectionSetNode> selectionSet, <ArrayObject> visitedFragmentNames = null, <ArrayObject> astAndDefs = null) -> <\ArrayObject>
    {
        var _visitedFragmentNames, _astAndDefs, selection, fieldName, fieldDef, tmp, schemaMetaFieldDef, typeMetaFieldDef, typeNameMetaFieldDef, responseName, fragName, fragment;
    
        let _visitedFragmentNames =  visitedFragmentNames ? visitedFragmentNames : new \ArrayObject();
        let _astAndDefs =  astAndDefs ? astAndDefs : new \ArrayObject();
        for selection in selectionSet->selections {
            if NodeKind::FIELD {
                /* @var FieldNode $selection */
                let fieldName =  selection->name->value;
                let fieldDef =  null;
                if parentType && method_exists(parentType, "getFields") {
                    let tmp =  parentType->getFields();
                    let schemaMetaFieldDef =  Introspection::schemaMetaFieldDef();
                    let typeMetaFieldDef =  Introspection::typeMetaFieldDef();
                    let typeNameMetaFieldDef =  Introspection::typeNameMetaFieldDef();
                    if fieldName === schemaMetaFieldDef->name && context->getSchema()->getQueryType() === parentType {
                        let fieldDef = schemaMetaFieldDef;
                    } elseif fieldName === typeMetaFieldDef->name && context->getSchema()->getQueryType() === parentType {
                        let fieldDef = typeMetaFieldDef;
                    } elseif fieldName === typeNameMetaFieldDef->name {
                        let fieldDef = typeNameMetaFieldDef;
                    } elseif isset tmp[fieldName] {
                        let fieldDef = tmp[fieldName];
                    }
                }
                let responseName =  this->getFieldName(selection);
                if !(isset _astAndDefs[responseName]) {
                    let _astAndDefs[responseName] = new \ArrayObject();
                }
                // create field context
                let _astAndDefs[responseName][] =  [selection, fieldDef];
            } elseif NodeKind::INLINE_FRAGMENT {
                /* @var InlineFragmentNode $selection */
                let _astAndDefs =  this->collectFieldASTsAndDefs(context, TypeInfo::typeFromAST(context->getSchema(), selection->typeCondition), selection->selectionSet, _visitedFragmentNames, _astAndDefs);
            } else {
                /* @var FragmentSpreadNode $selection */
                let fragName =  selection->name->value;
                if empty(_visitedFragmentNames[fragName]) {
                    let _visitedFragmentNames[fragName] = true;
                    let fragment =  context->getFragment(fragName);
                    if fragment {
                        let _astAndDefs =  this->collectFieldASTsAndDefs(context, TypeInfo::typeFromAST(context->getSchema(), fragment->typeCondition), fragment->selectionSet, _visitedFragmentNames, _astAndDefs);
                    }
                }
            }
        }
        return _astAndDefs;
    }
    
    protected function getFieldName(<FieldNode> node)
    {
        var fieldName, responseName;
    
        let fieldName =  node->name->value;
        let responseName =  node->alias ? node->alias->value  : fieldName;
        return responseName;
    }
    
    protected abstract function isEnabled() -> void;

}