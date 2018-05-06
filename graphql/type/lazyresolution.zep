namespace GraphQL\Type;

use GraphQL\Error\InvariantViolation;
use GraphQL\Type\Definition\AbstractType;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;
use GraphQL\Utils\Utils;
/**
 * EXPERIMENTAL!
 * This class can be removed or changed in future versions without a prior notice.
 *
 * Class LazyResolution
 * @package GraphQL\Type
 */
class LazyResolution implements Resolution
{
    /**
     * @var array
     */
    protected typeMap;
    /**
     * @var array
     */
    protected possibleTypeMap;
    /**
     * @var callable
     */
    protected typeLoader;
    /**
     * List of currently loaded types
     *
     * @var Type[]
     */
    protected loadedTypes;
    /**
     * Map of $interfaceTypeName => $objectType[]
     *
     * @var array
     */
    protected loadedPossibleTypes;
    /**
     * LazyResolution constructor.
     * @param array $descriptor
     * @param callable $typeLoader
     */
    public function __construct(array descriptor, typeLoader) -> void
    {
        Utils::invariant(isset descriptor["typeMap"], descriptor["possibleTypeMap"], descriptor["version"]);
        Utils::invariant(descriptor["version"] === "1.0");
        let this->typeLoader = typeLoader;
        let this->typeMap =  descriptor["typeMap"] + Type::getInternalTypes();
        let this->possibleTypeMap = descriptor["possibleTypeMap"];
        let this->loadedTypes =  Type::getInternalTypes();
        let this->loadedPossibleTypes =  [];
    }
    
    /**
     * @inheritdoc
     */
    public function resolveType(name) -> <Type>
    {
        var type;
    
        if !(isset this->typeMap[name]) {
            return null;
        }
        if !(isset this->loadedTypes[name]) {
            let type =  call_user_func(this->typeLoader, name);
            if !(type instanceof Type) && type !== null {
                throw new InvariantViolation("Lazy Type Resolution Error: Expecting GraphQL Type instance, but got " . Utils::getVariableType(type));
            }
            let this->loadedTypes[name] = type;
        }
        return this->loadedTypes[name];
    }
    
    /**
     * @inheritdoc
     */
    public function resolvePossibleTypes(<AbstractType> type) -> array
    {
        var tmpArray40cd750bba9870f18aada2478b24840a, tmp, typeName, true, obj;
    
        if !(isset this->possibleTypeMap[type->name]) {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return tmpArray40cd750bba9870f18aada2478b24840a;
        }
        if !(isset this->loadedPossibleTypes[type->name]) {
            let tmp =  [];
            for typeName, true in this->possibleTypeMap[type->name] {
                let obj =  this->resolveType(typeName);
                if !(obj instanceof ObjectType) {
                    throw new InvariantViolation("Lazy Type Resolution Error: Implementation {typeName} of interface {type->name} " . "is expected to be instance of ObjectType, but got " . Utils::getVariableType(obj));
                }
                let tmp[] = obj;
            }
            let this->loadedPossibleTypes[type->name] = tmp;
        }
        return this->loadedPossibleTypes[type->name];
    }

}