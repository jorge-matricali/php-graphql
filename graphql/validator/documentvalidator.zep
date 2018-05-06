namespace GraphQL\Validator;

use GraphQL\Error\Error;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\Visitor;
use GraphQL\Type\Schema;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\TypeInfo;
use GraphQL\Validator\Rules\AbstractValidationRule;
use GraphQL\Validator\Rules\ValuesOfCorrectType;
use GraphQL\Validator\Rules\DisableIntrospection;
use GraphQL\Validator\Rules\ExecutableDefinitions;
use GraphQL\Validator\Rules\FieldsOnCorrectType;
use GraphQL\Validator\Rules\FragmentsOnCompositeTypes;
use GraphQL\Validator\Rules\KnownArgumentNames;
use GraphQL\Validator\Rules\KnownDirectives;
use GraphQL\Validator\Rules\KnownFragmentNames;
use GraphQL\Validator\Rules\KnownTypeNames;
use GraphQL\Validator\Rules\LoneAnonymousOperation;
use GraphQL\Validator\Rules\NoFragmentCycles;
use GraphQL\Validator\Rules\NoUndefinedVariables;
use GraphQL\Validator\Rules\NoUnusedFragments;
use GraphQL\Validator\Rules\NoUnusedVariables;
use GraphQL\Validator\Rules\OverlappingFieldsCanBeMerged;
use GraphQL\Validator\Rules\PossibleFragmentSpreads;
use GraphQL\Validator\Rules\ProvidedNonNullArguments;
use GraphQL\Validator\Rules\QueryComplexity;
use GraphQL\Validator\Rules\QueryDepth;
use GraphQL\Validator\Rules\ScalarLeafs;
use GraphQL\Validator\Rules\UniqueArgumentNames;
use GraphQL\Validator\Rules\UniqueDirectivesPerLocation;
use GraphQL\Validator\Rules\UniqueFragmentNames;
use GraphQL\Validator\Rules\UniqueInputFieldNames;
use GraphQL\Validator\Rules\UniqueOperationNames;
use GraphQL\Validator\Rules\UniqueVariableNames;
use GraphQL\Validator\Rules\VariablesAreInputTypes;
use GraphQL\Validator\Rules\VariablesDefaultValueAllowed;
use GraphQL\Validator\Rules\VariablesInAllowedPosition;
/**
 * Implements the "Validation" section of the spec.
 *
 * Validation runs synchronously, returning an array of encountered errors, or
 * an empty array if no errors were encountered and the document is valid.
 *
 * A list of specific validation rules may be provided. If not provided, the
 * default list of rules defined by the GraphQL specification will be used.
 *
 * Each validation rule is an instance of GraphQL\Validator\Rules\AbstractValidationRule
 * which returns a visitor (see the [GraphQL\Language\Visitor API](reference.md#graphqllanguagevisitor)).
 *
 * Visitor methods are expected to return an instance of [GraphQL\Error\Error](reference.md#graphqlerrorerror),
 * or array of such instances when invalid.
 *
 * Optionally a custom TypeInfo instance may be provided. If not provided, one
 * will be created from the provided schema.
 */
class DocumentValidator
{
    protected static rules = [];
    protected static defaultRules;
    protected static securityRules;
    protected static initRules = false;
    /**
     * Primary method for query validation. See class description for details.
     *
     * @api
     * @param Schema $schema
     * @param DocumentNode $ast
     * @param AbstractValidationRule[]|null $rules
     * @param TypeInfo|null $typeInfo
     * @return Error[]
     */
    public static function validate(<Schema> schema, <DocumentNode> ast, array rules = null, <TypeInfo> typeInfo = null) -> array
    {
        var tmpArray40cd750bba9870f18aada2478b24840a, errors;
    
        if rules === null {
            let rules =  static::allRules();
        }
        if is_array(rules) === true && 0 === count(rules) {
            // Skip validation if there are no rules
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return tmpArray40cd750bba9870f18aada2478b24840a;
        }
        let typeInfo =  typeInfo ? typeInfo : new TypeInfo(schema);
        let errors =  static::visitUsingRules(schema, typeInfo, ast, rules);
        return errors;
    }
    
    /**
     * Returns all global validation rules.
     *
     * @api
     * @return AbstractValidationRule[]
     */
    public static function allRules() -> array
    {
        if !(self::initRules) {
            let static::rules =  array_merge(static::defaultRules(), self::securityRules(), self::rules);
            let static::initRules =  true;
        }
        return self::rules;
    }
    
    public static function defaultRules()
    {
        if self::defaultRules === null {
            let self::defaultRules =  [ExecutableDefinitions::class : new ExecutableDefinitions(), UniqueOperationNames::class : new UniqueOperationNames(), LoneAnonymousOperation::class : new LoneAnonymousOperation(), KnownTypeNames::class : new KnownTypeNames(), FragmentsOnCompositeTypes::class : new FragmentsOnCompositeTypes(), VariablesAreInputTypes::class : new VariablesAreInputTypes(), ScalarLeafs::class : new ScalarLeafs(), FieldsOnCorrectType::class : new FieldsOnCorrectType(), UniqueFragmentNames::class : new UniqueFragmentNames(), KnownFragmentNames::class : new KnownFragmentNames(), NoUnusedFragments::class : new NoUnusedFragments(), PossibleFragmentSpreads::class : new PossibleFragmentSpreads(), NoFragmentCycles::class : new NoFragmentCycles(), UniqueVariableNames::class : new UniqueVariableNames(), NoUndefinedVariables::class : new NoUndefinedVariables(), NoUnusedVariables::class : new NoUnusedVariables(), KnownDirectives::class : new KnownDirectives(), UniqueDirectivesPerLocation::class : new UniqueDirectivesPerLocation(), KnownArgumentNames::class : new KnownArgumentNames(), UniqueArgumentNames::class : new UniqueArgumentNames(), ValuesOfCorrectType::class : new ValuesOfCorrectType(), ProvidedNonNullArguments::class : new ProvidedNonNullArguments(), VariablesDefaultValueAllowed::class : new VariablesDefaultValueAllowed(), VariablesInAllowedPosition::class : new VariablesInAllowedPosition(), OverlappingFieldsCanBeMerged::class : new OverlappingFieldsCanBeMerged(), UniqueInputFieldNames::class : new UniqueInputFieldNames()];
        }
        return self::defaultRules;
    }
    
    /**
     * @return array
     */
    public static function securityRules() -> array
    {
        // This way of defining rules is deprecated
        // When custom security rule is required - it should be just added via DocumentValidator::addRule();
        // TODO: deprecate this
        if self::securityRules === null {
            let self::securityRules =  [DisableIntrospection::class : new DisableIntrospection(DisableIntrospection::DISABLED), QueryDepth::class : new QueryDepth(QueryDepth::DISABLED), QueryComplexity::class : new QueryComplexity(QueryComplexity::DISABLED)];
        }
        return self::securityRules;
    }
    
    /**
     * Returns global validation rule by name. Standard rules are named by class name, so
     * example usage for such rules:
     *
     * $rule = DocumentValidator::getRule(GraphQL\Validator\Rules\QueryComplexity::class);
     *
     * @api
     * @param string $name
     * @return AbstractValidationRule
     */
    public static function getRule(string name) -> <AbstractValidationRule>
    {
        var rules;
    
        let rules =  static::allRules();
        if isset rules[name] {
            return rules[name];
        }
        let name = "GraphQL\\Validator\\Rules\\{name}";
        return  isset rules[name] ? rules[name]  : null;
    }
    
    /**
     * Add rule to list of global validation rules
     *
     * @api
     * @param AbstractValidationRule $rule
     */
    public static function addRule(<AbstractValidationRule> rule) -> void
    {
        var tmpRule1;
    
        
        rule->getName();
        let tmpRule1 = rule;
        
        let self::rules[tmpRule1] = rule;
    }
    
    public static function isError(value)
    {
        return  is_array(value) ? count(array_filter(value, new DocumentValidatorisErrorClosureOne())) === count(value)  : value instanceof \Exception || value instanceof \Throwable;
    }
    
    public static function append(arr, items)
    {
        if is_array(items) {
            let arr =  array_merge(arr, items);
        } else {
            let arr[] = items;
        }
        return arr;
    }
    
    /**
     * Utility which determines if a value literal node is valid for an input type.
     *
     * Deprecated. Rely on validation for documents containing literal values.
     *
     * @deprecated
     * @return Error[]
     */
    public static function isValidLiteralValue(<Type> type, valueNode) -> array
    {
        var emptySchema, tmpArray40cd750bba9870f18aada2478b24840a, emptyDoc, tmpArrayab6ce43d41fc3e5f260c4198af8461b6, typeInfo, context, validator, visitor;
    
        let emptySchema =  new Schema([]);
        let emptyDoc =  new DocumentNode(["definitions" : []]);
        let typeInfo =  new TypeInfo(emptySchema, type);
        let context =  new ValidationContext(emptySchema, emptyDoc, typeInfo);
        let validator =  new ValuesOfCorrectType();
        let visitor =  validator->getVisitor(context);
        Visitor::visit(valueNode, Visitor::visitWithTypeInfo(typeInfo, visitor));
        return context->getErrors();
    }
    
    /**
     * This uses a specialized visitor which runs multiple visitors in parallel,
     * while maintaining the visitor skip and break API.
     *
     * @param Schema $schema
     * @param TypeInfo $typeInfo
     * @param DocumentNode $documentNode
     * @param AbstractValidationRule[] $rules
     * @return array
     */
    public static function visitUsingRules(<Schema> schema, <TypeInfo> typeInfo, <DocumentNode> documentNode, array rules) -> array
    {
        var context, visitors, rule;
    
        let context =  new ValidationContext(schema, documentNode, typeInfo);
        let visitors =  [];
        for rule in rules {
            let visitors[] =  rule->getVisitor(context);
        }
        Visitor::visit(documentNode, Visitor::visitWithTypeInfo(typeInfo, Visitor::visitInParallel(visitors)));
        return context->getErrors();
    }

}