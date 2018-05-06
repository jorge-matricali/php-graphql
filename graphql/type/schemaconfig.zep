namespace GraphQL\Type;

use GraphQL\Language\AST\SchemaDefinitionNode;
use GraphQL\Type\Definition\Directive;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\Utils;
/**
 * Schema configuration class.
 * Could be passed directly to schema constructor. List of options accepted by **create** method is
 * [described in docs](type-system/schema.md#configuration-options).
 *
 * Usage example:
 *
 *     $config = SchemaConfig::create()
 *         ->setQuery($myQueryType)
 *         ->setTypeLoader($myTypeLoader);
 *
 *     $schema = new Schema($config);
 *
 */
class SchemaConfig
{
    /**
     * @var ObjectType
     */
    public query;
    /**
     * @var ObjectType
     */
    public mutation;
    /**
     * @var ObjectType
     */
    public subscription;
    /**
     * @var Type[]|callable
     */
    public types;
    /**
     * @var Directive[]
     */
    public directives;
    /**
     * @var callable
     */
    public typeLoader;
    /**
     * @var SchemaDefinitionNode
     */
    public astNode;
    /**
     * @var bool
     */
    public assumeValid;
    /**
     * Converts an array of options to instance of SchemaConfig
     * (or just returns empty config when array is not passed).
     *
     * @api
     * @param array $options
     * @return SchemaConfig
     */
    public static function create(array options = []) -> <SchemaConfig>
    {
        var config, strategy;
    
        let config =  new static();
        if !(empty(options)) {
            if isset options["query"] {
                config->setQuery(options["query"]);
            }
            if isset options["mutation"] {
                config->setMutation(options["mutation"]);
            }
            if isset options["subscription"] {
                config->setSubscription(options["subscription"]);
            }
            if isset options["types"] {
                config->setTypes(options["types"]);
            }
            if isset options["directives"] {
                config->setDirectives(options["directives"]);
            }
            if isset options["typeResolution"] {
                trigger_error("Type resolution strategies are deprecated. Just pass single option `typeLoader` " . "to schema constructor instead.", E_USER_DEPRECATED);
                if options["typeResolution"] instanceof Resolution && !(isset options["typeLoader"]) {
                    let strategy = options["typeResolution"];
                    let options["typeLoader"] = new SchemaConfigcreateClosureOne(strategy);
                }
            }
            if isset options["typeLoader"] {
                Utils::invariant(is_callable(options["typeLoader"]), "Schema type loader must be callable if provided but got: %s", Utils::printSafe(options["typeLoader"]));
                config->setTypeLoader(options["typeLoader"]);
            }
            if isset options["astNode"] {
                config->setAstNode(options["astNode"]);
            }
            if isset options["assumeValid"] {
                config->setAssumeValid((bool) options["assumeValid"]);
            }
        }
        return config;
    }
    
    /**
     * @return SchemaDefinitionNode
     */
    public function getAstNode() -> <SchemaDefinitionNode>
    {
        return this->astNode;
    }
    
    /**
     * @param SchemaDefinitionNode $astNode
     * @return SchemaConfig
     */
    public function setAstNode(<SchemaDefinitionNode> astNode) -> <SchemaConfig>
    {
        let this->astNode = astNode;
        return this;
    }
    
    /**
     * @api
     * @param ObjectType $query
     * @return SchemaConfig
     */
    public function setQuery(<ObjectType> query) -> <SchemaConfig>
    {
        let this->query = query;
        return this;
    }
    
    /**
     * @api
     * @param ObjectType $mutation
     * @return SchemaConfig
     */
    public function setMutation(<ObjectType> mutation) -> <SchemaConfig>
    {
        let this->mutation = mutation;
        return this;
    }
    
    /**
     * @api
     * @param ObjectType $subscription
     * @return SchemaConfig
     */
    public function setSubscription(<ObjectType> subscription) -> <SchemaConfig>
    {
        let this->subscription = subscription;
        return this;
    }
    
    /**
     * @api
     * @param Type[]|callable $types
     * @return SchemaConfig
     */
    public function setTypes(types) -> <SchemaConfig>
    {
        let this->types = types;
        return this;
    }
    
    /**
     * @api
     * @param Directive[] $directives
     * @return SchemaConfig
     */
    public function setDirectives(array directives) -> <SchemaConfig>
    {
        let this->directives = directives;
        return this;
    }
    
    /**
     * @api
     * @param callable $typeLoader
     * @return SchemaConfig
     */
    public function setTypeLoader(typeLoader) -> <SchemaConfig>
    {
        let this->typeLoader = typeLoader;
        return this;
    }
    
    /**
     * @param bool $assumeValid
     * @return SchemaConfig
     */
    public function setAssumeValid(bool assumeValid) -> <SchemaConfig>
    {
        let this->assumeValid = assumeValid;
        return this;
    }
    
    /**
     * @api
     * @return ObjectType
     */
    public function getQuery() -> <ObjectType>
    {
        return this->query;
    }
    
    /**
     * @api
     * @return ObjectType
     */
    public function getMutation() -> <ObjectType>
    {
        return this->mutation;
    }
    
    /**
     * @api
     * @return ObjectType
     */
    public function getSubscription() -> <ObjectType>
    {
        return this->subscription;
    }
    
    /**
     * @api
     * @return Type[]
     */
    public function getTypes() -> array
    {
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  this->types ? this->types : tmpArray40cd750bba9870f18aada2478b24840a;
    }
    
    /**
     * @api
     * @return Directive[]
     */
    public function getDirectives() -> array
    {
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  this->directives ? this->directives : tmpArray40cd750bba9870f18aada2478b24840a;
    }
    
    /**
     * @api
     * @return callable
     */
    public function getTypeLoader()
    {
        return this->typeLoader;
    }
    
    /**
     * @return bool
     */
    public function getAssumeValid() -> bool
    {
        return this->assumeValid;
    }

}