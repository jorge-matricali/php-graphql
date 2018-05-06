namespace GraphQL\Type;

use GraphQL\Type\Definition\AbstractType;
use GraphQL\Type\Definition\FieldArgument;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\UnionType;
use GraphQL\Type\Definition\WrappingType;
use GraphQL\Utils\TypeInfo;
use GraphQL\Utils\Utils;
/**
 * EXPERIMENTAL!
 * This class can be removed or changed in future versions without a prior notice.
 *
 * Class EagerResolution
 * @package GraphQL\Type
 */
class EagerResolution implements Resolution
{
    /**
     * @var Type[]
     */
    protected typeMap = [];
    /**
     * @var array<string, ObjectType[]>
     */
    protected implementations = [];
    /**
     * EagerResolution constructor.
     * @param Type[] $initialTypes
     */
    public function __construct(array initialTypes) -> void
    {
        var typeMap, type, typeName, iface;
    
        let typeMap =  [];
        for type in initialTypes {
            let typeMap =  TypeInfo::extractTypes(type, typeMap);
        }
        let this->typeMap =  typeMap + Type::getInternalTypes();
        // Keep track of all possible types for abstract types
        for typeName, type in this->typeMap {
            if type instanceof ObjectType {
                for iface in type->getInterfaces() {
                    let this->implementations[iface->name][] = type;
                }
            }
        }
    }
    
    /**
     * @inheritdoc
     */
    public function resolveType(name) -> <Type>
    {
        return  isset this->typeMap[name] ? this->typeMap[name]  : null;
    }
    
    /**
     * @inheritdoc
     */
    public function resolvePossibleTypes(<AbstractType> abstractType) -> array
    {
        var tmpArray40cd750bba9870f18aada2478b24840a;
    
        if !(isset this->typeMap[abstractType->name]) {
            let tmpArray40cd750bba9870f18aada2478b24840a = [];
            return tmpArray40cd750bba9870f18aada2478b24840a;
        }
        if abstractType instanceof UnionType {
            return abstractType->getTypes();
        }
        /** @var InterfaceType $abstractType */
        Utils::invariant(abstractType instanceof InterfaceType);
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return  isset this->implementations[abstractType->name] ? this->implementations[abstractType->name]  : tmpArray40cd750bba9870f18aada2478b24840a;
    }
    
    /**
     * @return Type[]
     */
    public function getTypeMap() -> array
    {
        return this->typeMap;
    }
    
    /**
     * Returns serializable schema representation suitable for GraphQL\Type\LazyResolution
     *
     * @return array
     */
    public function getDescriptor() -> array
    {
        var typeMap, possibleTypesMap, type, innerType, obj, tmpArrayea3d7ad5121b03adb50e18a4226f80fd;
    
        let typeMap =  [];
        let possibleTypesMap =  [];
        for type in this->getTypeMap() {
            if type instanceof UnionType {
                for innerType in type->getTypes() {
                    let possibleTypesMap[type->name][innerType->name] = 1;
                }
            } else {
                if type instanceof InterfaceType {
                    for obj in this->implementations[type->name] {
                        let possibleTypesMap[type->name][obj->name] = 1;
                    }
                }
            }
            let typeMap[type->name] = 1;
        }
        let tmpArrayea3d7ad5121b03adb50e18a4226f80fd = ["version" : "1.0", "typeMap" : typeMap, "possibleTypeMap" : possibleTypesMap];
        return tmpArrayea3d7ad5121b03adb50e18a4226f80fd;
    }

}