namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Executor\Values;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\FragmentSpreadNode;
use GraphQL\Language\AST\InlineFragmentNode;
use GraphQL\Language\AST\Node;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\OperationDefinitionNode;
use GraphQL\Language\AST\SelectionSetNode;
use GraphQL\Language\Visitor;
use GraphQL\Type\Definition\Directive;
use GraphQL\Type\Definition\FieldDefinition;
use GraphQL\Validator\ValidationContext;
class QueryComplexity extends AbstractQuerySecurity
{
    protected maxQueryComplexity;
    protected rawVariableValues = [];
    protected variableDefs;
    protected fieldNodeAndDefs;
    /**
     * @var ValidationContext
     */
    protected context;
    public function __construct(maxQueryComplexity) -> void
    {
        this->setMaxQueryComplexity(maxQueryComplexity);
    }
    
    public static function maxQueryComplexityErrorMessage(max, count)
    {
        return sprintf("Max query complexity should be %d but got %d.", max, count);
    }
    
    /**
     * Set max query complexity. If equal to 0 no check is done. Must be greater or equal to 0.
     *
     * @param $maxQueryComplexity
     */
    public function setMaxQueryComplexity(maxQueryComplexity) -> void
    {
        this->checkIfGreaterOrEqualToZero("maxQueryComplexity", maxQueryComplexity);
        let this->maxQueryComplexity =  (int) maxQueryComplexity;
    }
    
    public function getMaxQueryComplexity()
    {
        return this->maxQueryComplexity;
    }
    
    public function setRawVariableValues(array rawVariableValues = null) -> void
    {
        let this->rawVariableValues =  rawVariableValues ? rawVariableValues : [];
    }
    
    public function getRawVariableValues()
    {
        return this->rawVariableValues;
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var complexity, tmpArrayb2327d18344a90505fb5cae1364234e7, errors;
    
        let this->context = context;
        let this->variableDefs =  new \ArrayObject();
        let this->fieldNodeAndDefs =  new \ArrayObject();
        let complexity = 0;
        let tmpArrayb2327d18344a90505fb5cae1364234e7 = let this->fieldNodeAndDefs =  this->collectFieldASTsAndDefs(context, context->getParentType(), selectionSet, null, this->fieldNodeAndDefs);
        let this->variableDefs[] = def;
        let errors =  context->getErrors();
        let complexity =  this->fieldComplexity(operationDefinition, complexity);
        [NodeKind::SELECTION_SET : new QueryComplexitygetVisitorClosureOne(context), NodeKind::VARIABLE_DEFINITION : new QueryComplexitygetVisitorClosureOne(), NodeKind::OPERATION_DEFINITION : ["leave" : new QueryComplexitygetVisitorClosureOne(context, complexity)]];
        let this->fieldNodeAndDefs =  this->collectFieldASTsAndDefs(context, context->getParentType(), selectionSet, null, this->fieldNodeAndDefs);
        let this->variableDefs[] = def;
        let errors =  context->getErrors();
        let complexity =  this->fieldComplexity(operationDefinition, complexity);
        return this->invokeIfNeeded(context, tmpArray6b5ee891d90bd45e0e0f357d7f3cc693);
    }
    
    protected function fieldComplexity(node, complexity = 0)
    {
        var childNode;
    
        if isset node->selectionSet && node->selectionSet instanceof SelectionSetNode {
            for childNode in node->selectionSet->selections {
                let complexity =  this->nodeComplexity(childNode, complexity);
            }
        }
        return complexity;
    }
    
    protected function nodeComplexity(<Node> node, complexity = 0)
    {
        var args, complexityFn, childrenComplexity, astFieldInfo, fieldDef, tmpArraya86a216fe585582cb9bf2063980d32d3, fragment;
    
        if NodeKind::FIELD {
            /* @var FieldNode $node */
            // default values
            let args =  [];
            let complexityFn =  FieldDefinition::DEFAULT_COMPLEXITY_FN;
            // calculate children complexity if needed
            let childrenComplexity = 0;
            // node has children?
            if isset node->selectionSet {
                let childrenComplexity =  this->fieldComplexity(node);
            }
            let astFieldInfo =  this->astFieldInfo(node);
            let fieldDef = astFieldInfo[1];
            if fieldDef instanceof FieldDefinition {
                if this->directiveExcludesField(node) {
                    break;
                }
                let args =  this->buildFieldArguments(node);
                //get complexity fn using fieldDef complexity
                if method_exists(fieldDef, "getComplexityFn") {
                    let complexityFn =  fieldDef->getComplexityFn();
                }
            }
            let complexity += let tmpArraya86a216fe585582cb9bf2063980d32d3 = [childrenComplexity, args];
            call_user_func_array(complexityFn, tmpArraya86a216fe585582cb9bf2063980d32d3);
        } elseif NodeKind::INLINE_FRAGMENT {
            /* @var InlineFragmentNode $node */
            // node has children?
            if isset node->selectionSet {
                let complexity =  this->fieldComplexity(node, complexity);
            }
        } else {
            /* @var FragmentSpreadNode $node */
            let fragment =  this->getFragment(node);
            if fragment !== null {
                let complexity =  this->fieldComplexity(fragment, complexity);
            }
        }
        return complexity;
    }
    
    protected function astFieldInfo(<FieldNode> field)
    {
        var fieldName, astFieldInfo, astAndDef;
    
        let fieldName =  this->getFieldName(field);
        let astFieldInfo =  [null, null];
        if isset this->fieldNodeAndDefs[fieldName] {
            for astAndDef in this->fieldNodeAndDefs[fieldName] {
                if astAndDef[0] == field {
                    let astFieldInfo = astAndDef;
                    break;
                }
            }
        }
        return astFieldInfo;
    }
    
    protected function buildFieldArguments(<FieldNode> node)
    {
        var rawVariableValues, astFieldInfo, fieldDef, args, variableValuesResult, variableValues;
    
        let rawVariableValues =  this->getRawVariableValues();
        let astFieldInfo =  this->astFieldInfo(node);
        let fieldDef = astFieldInfo[1];
        let args =  [];
        if fieldDef instanceof FieldDefinition {
            let variableValuesResult =  Values::getVariableValues(this->context->getSchema(), this->variableDefs, rawVariableValues);
            if variableValuesResult["errors"] {
                throw new Error(implode("

", array_map(new QueryComplexitybuildFieldArgumentsClosureOne(), variableValuesResult["errors"])));
            }
            let variableValues = variableValuesResult["coerced"];
            let args =  Values::getArgumentValues(fieldDef, node, variableValues);
        }
        return args;
    }
    
    protected function directiveExcludesField(<FieldNode> node)
    {
        var directiveNode, variableValuesResult, variableValues, directive, directiveArgs;
    
        for directiveNode in node->directives {
            if directiveNode->name->value === "deprecated" {
                return false;
            }
            let variableValuesResult =  Values::getVariableValues(this->context->getSchema(), this->variableDefs, this->getRawVariableValues());
            if variableValuesResult["errors"] {
                throw new Error(implode("

", array_map(new QueryComplexitydirectiveExcludesFieldClosureOne(), variableValuesResult["errors"])));
            }
            let variableValues = variableValuesResult["coerced"];
            if directiveNode->name->value === "include" {
                let directive =  Directive::includeDirective();
                let directiveArgs =  Values::getArgumentValues(directive, directiveNode, variableValues);
                return !(directiveArgs["if"]);
            } else {
                let directive =  Directive::skipDirective();
                let directiveArgs =  Values::getArgumentValues(directive, directiveNode, variableValues);
                return directiveArgs["if"];
            }
        }
    }
    
    protected function isEnabled()
    {
        return this->getMaxQueryComplexity() !== static::DISABLED;
    }

}