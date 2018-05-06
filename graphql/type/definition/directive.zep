namespace GraphQL\Type\Definition;

use GraphQL\Language\AST\DirectiveDefinitionNode;
use GraphQL\Language\DirectiveLocation;
use GraphQL\Utils\Utils;
/**
 * Class Directive
 * @package GraphQL\Type\Definition
 */
class Directive
{
    const DEFAULT_DEPRECATION_REASON = "No longer supported";
    /**
     * @var array
     */
    public static internalDirectives;
    // Schema Definitions
    /**
     * @return Directive
     */
    public static function includeDirective()
    {
        var internall;
    
        let internall =  self::getInternalDirectives();
        return internall["include"];
    }
    
    /**
     * @return Directive
     */
    public static function skipDirective() -> <Directive>
    {
        var internall;
    
        let internall =  self::getInternalDirectives();
        return internall["skip"];
    }
    
    /**
     * @return Directive
     */
    public static function deprecatedDirective() -> <Directive>
    {
        var internall;
    
        let internall =  self::getInternalDirectives();
        return internall["deprecated"];
    }
    
    /**
     * @param Directive $directive
     * @return bool
     */
    public static function isSpecifiedDirective(<Directive> directive) -> bool
    {
        return in_array(directive->name, array_keys(self::getInternalDirectives()));
    }
    
    /**
     * @return array
     */
    public static function getInternalDirectives() -> array
    {
        var tmpArray637df777a6b232ce4ea61564cb77565b, tmpArray9779f9ad5790e9a0cb958e87339b79b4, tmpArrayf5eddbadde031f493a4ae9482d6fe216, tmpArrayf11508373d00d85a6cc464b0f2c0553f, tmpArray488fb6b2c0480b1712b59856bb3b90bb, tmpArrayc490dc28dd5e14dbf91093b73cb8e576;
    
        if !(self::internalDirectives) {
            let self::internalDirectives =  ["include" : new self(tmpArray637df777a6b232ce4ea61564cb77565b), "skip" : new self(tmpArrayf5eddbadde031f493a4ae9482d6fe216), "deprecated" : new self(tmpArray488fb6b2c0480b1712b59856bb3b90bb)];
        }
        return self::internalDirectives;
    }
    
    /**
     * @var string
     */
    public name;
    /**
     * @var string|null
     */
    public description;
    /**
     * Values from self::$locationMap
     *
     * @var array
     */
    public locations;
    /**
     * @var FieldArgument[]
     */
    public args;
    /**
     * @var DirectiveDefinitionNode|null
     */
    public astNode;
    /**
     * @var array
     */
    public config;
    /**
     * Directive constructor.
     * @param array $config
     */
    public function __construct(array config) -> void
    {
        var key, value;
    
        for key, value in config {
            let this->{key} = value;
        }
        Utils::invariant(this->name, "Directive must be named.");
        Utils::invariant(is_array(this->locations), "Must provide locations for directive.");
        let this->config = config;
    }

}