/**
 * Utility for finding breaking/dangerous changes between two schemas.
 */
namespace GraphQL\Utils;

use GraphQL\Type\Definition\Directive;
use GraphQL\Type\Definition\EnumType;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\ListOfType;
use GraphQL\Type\Definition\NamedType;
use GraphQL\Type\Definition\NonNull;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\ScalarType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\UnionType;
use GraphQL\Type\Schema;
class FindBreakingChanges
{
    const BREAKING_CHANGE_FIELD_CHANGED_KIND = "FIELD_CHANGED_KIND";
    const BREAKING_CHANGE_FIELD_REMOVED = "FIELD_REMOVED";
    const BREAKING_CHANGE_TYPE_CHANGED_KIND = "TYPE_CHANGED_KIND";
    const BREAKING_CHANGE_TYPE_REMOVED = "TYPE_REMOVED";
    const BREAKING_CHANGE_TYPE_REMOVED_FROM_UNION = "TYPE_REMOVED_FROM_UNION";
    const BREAKING_CHANGE_VALUE_REMOVED_FROM_ENUM = "VALUE_REMOVED_FROM_ENUM";
    const BREAKING_CHANGE_ARG_REMOVED = "ARG_REMOVED";
    const BREAKING_CHANGE_ARG_CHANGED_KIND = "ARG_CHANGED_KIND";
    const BREAKING_CHANGE_NON_NULL_ARG_ADDED = "NON_NULL_ARG_ADDED";
    const BREAKING_CHANGE_NON_NULL_INPUT_FIELD_ADDED = "NON_NULL_INPUT_FIELD_ADDED";
    const BREAKING_CHANGE_INTERFACE_REMOVED_FROM_OBJECT = "INTERFACE_REMOVED_FROM_OBJECT";
    const BREAKING_CHANGE_DIRECTIVE_REMOVED = "DIRECTIVE_REMOVED";
    const BREAKING_CHANGE_DIRECTIVE_ARG_REMOVED = "DIRECTIVE_ARG_REMOVED";
    const BREAKING_CHANGE_DIRECTIVE_LOCATION_REMOVED = "DIRECTIVE_LOCATION_REMOVED";
    const BREAKING_CHANGE_NON_NULL_DIRECTIVE_ARG_ADDED = "NON_NULL_DIRECTIVE_ARG_ADDED";
    const DANGEROUS_CHANGE_ARG_DEFAULT_VALUE_CHANGED = "ARG_DEFAULT_VALUE_CHANGE";
    const DANGEROUS_CHANGE_VALUE_ADDED_TO_ENUM = "VALUE_ADDED_TO_ENUM";
    const DANGEROUS_CHANGE_INTERFACE_ADDED_TO_OBJECT = "INTERFACE_ADDED_TO_OBJECT";
    const DANGEROUS_CHANGE_TYPE_ADDED_TO_UNION = "TYPE_ADDED_TO_UNION";
    const DANGEROUS_CHANGE_NULLABLE_INPUT_FIELD_ADDED = "NULLABLE_INPUT_FIELD_ADDED";
    const DANGEROUS_CHANGE_NULLABLE_ARG_ADDED = "NULLABLE_ARG_ADDED";
    /**
     * Given two schemas, returns an Array containing descriptions of all the types
     * of breaking changes covered by the other functions down below.
     *
     * @return array
     */
    public static function findBreakingChanges(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        return array_merge(self::findRemovedTypes(oldSchema, newSchema), self::findTypesThatChangedKind(oldSchema, newSchema), self::findFieldsThatChangedTypeOnObjectOrInterfaceTypes(oldSchema, newSchema), self::findFieldsThatChangedTypeOnInputObjectTypes(oldSchema, newSchema)["breakingChanges"], self::findTypesRemovedFromUnions(oldSchema, newSchema), self::findValuesRemovedFromEnums(oldSchema, newSchema), self::findArgChanges(oldSchema, newSchema)["breakingChanges"], self::findInterfacesRemovedFromObjectTypes(oldSchema, newSchema), self::findRemovedDirectives(oldSchema, newSchema), self::findRemovedDirectiveArgs(oldSchema, newSchema), self::findAddedNonNullDirectiveArgs(oldSchema, newSchema), self::findRemovedDirectiveLocations(oldSchema, newSchema));
    }
    
    /**
     * Given two schemas, returns an Array containing descriptions of all the types
     * of potentially dangerous changes covered by the other functions down below.
     *
     * @return array
     */
    public static function findDangerousChanges(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        return array_merge(self::findArgChanges(oldSchema, newSchema)["dangerousChanges"], self::findValuesAddedToEnums(oldSchema, newSchema), self::findInterfacesAddedToObjectTypes(oldSchema, newSchema), self::findTypesAddedToUnions(oldSchema, newSchema), self::findFieldsThatChangedTypeOnInputObjectTypes(oldSchema, newSchema)["dangerousChanges"]);
    }
    
    /**
     * Given two schemas, returns an Array containing descriptions of any breaking
     * changes in the newSchema related to removing an entire type.
     *
     * @return array
     */
    public static function findRemovedTypes(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, breakingChanges, typeName;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let breakingChanges =  [];
        for typeName in array_keys(oldTypeMap) {
            if !(isset newTypeMap[typeName]) {
                let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_TYPE_REMOVED, "description" : "{typeName} was removed."];
            }
        }
        return breakingChanges;
    }
    
    /**
     * Given two schemas, returns an Array containing descriptions of any breaking
     * changes in the newSchema related to changing the type of a type.
     *
     * @return array
     */
    public static function findTypesThatChangedKind(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, breakingChanges, typeName, oldType, newType, oldTypeKindName, newTypeKindName;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let breakingChanges =  [];
        for typeName, oldType in oldTypeMap {
            if !(isset newTypeMap[typeName]) {
                continue;
            }
            let newType = newTypeMap[typeName];
            if !(oldType instanceof newType) {
                let oldTypeKindName =  self::typeKindName(oldType);
                let newTypeKindName =  self::typeKindName(newType);
                let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_TYPE_CHANGED_KIND, "description" : "{typeName} changed from {oldTypeKindName} to {newTypeKindName}."];
            }
        }
        return breakingChanges;
    }
    
    /**
     * Given two schemas, returns an Array containing descriptions of any
     * breaking or dangerous changes in the newSchema related to arguments
     * (such as removal or change of type of an argument, or a change in an
     * argument's default value).
     *
     * @return array
     */
    public static function findArgChanges(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, breakingChanges, dangerousChanges, typeName, oldType, newType, oldTypeFields, newTypeFields, fieldName, oldField, oldArgDef, newArgs, newArgDef, isSafe, oldArgType, oldArgName, newArgType, oldArgs, newTypeName, newArgName, tmpArray6f1c74a58cb0054c4efbaa337315e3a0;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let breakingChanges =  [];
        let dangerousChanges =  [];
        for typeName, oldType in oldTypeMap {
            let newType =  isset newTypeMap[typeName] ? newTypeMap[typeName]  : null;
            if !((oldType instanceof ObjectType || oldType instanceof InterfaceType)) || !((newType instanceof ObjectType || newType instanceof InterfaceType)) || !(newType instanceof oldType) {
                continue;
            }
            let oldTypeFields =  oldType->getFields();
            let newTypeFields =  newType->getFields();
            for fieldName, oldField in oldTypeFields {
                if !(isset newTypeFields[fieldName]) {
                    continue;
                }
                for oldArgDef in oldField->args {
                    let newArgs =  newTypeFields[fieldName]->args;
                    let newArgDef =  Utils::find(newArgs, new FindBreakingChangesfindArgChangesClosureOne(oldArgDef));
                    if !(newArgDef) {
                        let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_ARG_REMOVED, "description" : "{typeName}.{fieldName} arg {oldArgDef->name} was removed"];
                    } else {
                        let isSafe =  self::isChangeSafeForInputObjectFieldOrFieldArg(oldArgDef->getType(), newArgDef->getType());
                        let oldArgType =  oldArgDef->getType();
                        let oldArgName =  oldArgDef->name;
                        if !(isSafe) {
                            let newArgType =  newArgDef->getType();
                            let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_ARG_CHANGED_KIND, "description" : "{typeName}.{fieldName} arg {oldArgName} has changed type from {oldArgType} to {newArgType}"];
                        } elseif oldArgDef->defaultValueExists() && oldArgDef->defaultValue !== newArgDef->defaultValue {
                            let dangerousChanges[] =  ["type" : FindBreakingChanges::DANGEROUS_CHANGE_ARG_DEFAULT_VALUE_CHANGED, "description" : "{typeName}.{fieldName} arg {oldArgName} has changed defaultValue"];
                        }
                    }
                    // Check if a non-null arg was added to the field
                    for newArgDef in newTypeFields[fieldName]->args {
                        let oldArgs =  oldTypeFields[fieldName]->args;
                        let oldArgDef =  Utils::find(oldArgs, new FindBreakingChangesfindArgChangesClosureOne(newArgDef));
                        if !(oldArgDef) {
                            let newTypeName =  newType->name;
                            let newArgName =  newArgDef->name;
                            if newArgDef->getType() instanceof NonNull {
                                let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_NON_NULL_ARG_ADDED, "description" : "A non-null arg {newArgName} on {newTypeName}.{fieldName} was added"];
                            } else {
                                let dangerousChanges[] =  ["type" : self::DANGEROUS_CHANGE_NULLABLE_ARG_ADDED, "description" : "A nullable arg {newArgName} on {newTypeName}.{fieldName} was added"];
                            }
                        }
                    }
                }
            }
        }
        let tmpArray6f1c74a58cb0054c4efbaa337315e3a0 = ["breakingChanges" : breakingChanges, "dangerousChanges" : dangerousChanges];
        return tmpArray6f1c74a58cb0054c4efbaa337315e3a0;
    }
    
    /**
     * @param Type $type
     * @return string
     *
     * @throws \TypeError
     */
    protected static function typeKindName(<Type> type) -> string
    {
        if type instanceof ScalarType {
            return "a Scalar type";
        } elseif type instanceof ObjectType {
            return "an Object type";
        } elseif type instanceof InterfaceType {
            return "an Interface type";
        } elseif type instanceof UnionType {
            return "a Union type";
        } elseif type instanceof EnumType {
            return "an Enum type";
        } elseif type instanceof InputObjectType {
            return "an Input type";
        }
        throw new \TypeError("unknown type " . type->name);
    }
    
    public static function findFieldsThatChangedTypeOnObjectOrInterfaceTypes(<Schema> oldSchema, <Schema> newSchema)
    {
        var oldTypeMap, newTypeMap, breakingChanges, typeName, oldType, newType, oldTypeFieldsDef, newTypeFieldsDef, fieldName, fieldDefinition, oldFieldType, newFieldType, isSafe, oldFieldTypeString, newFieldTypeString;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let breakingChanges =  [];
        for typeName, oldType in oldTypeMap {
            let newType =  isset newTypeMap[typeName] ? newTypeMap[typeName]  : null;
            if !((oldType instanceof ObjectType || oldType instanceof InterfaceType)) || !((newType instanceof ObjectType || newType instanceof InterfaceType)) || !(newType instanceof oldType) {
                continue;
            }
            let oldTypeFieldsDef =  oldType->getFields();
            let newTypeFieldsDef =  newType->getFields();
            for fieldName, fieldDefinition in oldTypeFieldsDef {
                // Check if the field is missing on the type in the new schema.
                if !(isset newTypeFieldsDef[fieldName]) {
                    let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_FIELD_REMOVED, "description" : "{typeName}.{fieldName} was removed."];
                } else {
                    let oldFieldType =  oldTypeFieldsDef[fieldName]->getType();
                    let newFieldType =  newTypeFieldsDef[fieldName]->getType();
                    let isSafe =  self::isChangeSafeForObjectOrInterfaceField(oldFieldType, newFieldType);
                    if !(isSafe) {
                        let oldFieldTypeString =  oldFieldType instanceof NamedType ? oldFieldType->name  : oldFieldType;
                        let newFieldTypeString =  newFieldType instanceof NamedType ? newFieldType->name  : newFieldType;
                        let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_FIELD_CHANGED_KIND, "description" : "{typeName}.{fieldName} changed type from {oldFieldTypeString} to {newFieldTypeString}."];
                    }
                }
            }
        }
        return breakingChanges;
    }
    
    public static function findFieldsThatChangedTypeOnInputObjectTypes(<Schema> oldSchema, <Schema> newSchema)
    {
        var oldTypeMap, newTypeMap, breakingChanges, dangerousChanges, typeName, oldType, newType, oldTypeFieldsDef, newTypeFieldsDef, fieldName, oldFieldType, newFieldType, isSafe, oldFieldTypeString, newFieldTypeString, fieldDef, newTypeName, tmpArrayd73a0b4397d6ef8e78a102cf357061fc;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let breakingChanges =  [];
        let dangerousChanges =  [];
        for typeName, oldType in oldTypeMap {
            let newType =  isset newTypeMap[typeName] ? newTypeMap[typeName]  : null;
            if !(oldType instanceof InputObjectType) || !(newType instanceof InputObjectType) {
                continue;
            }
            let oldTypeFieldsDef =  oldType->getFields();
            let newTypeFieldsDef =  newType->getFields();
            for fieldName in array_keys(oldTypeFieldsDef) {
                if !(isset newTypeFieldsDef[fieldName]) {
                    let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_FIELD_REMOVED, "description" : "{typeName}.{fieldName} was removed."];
                } else {
                    let oldFieldType =  oldTypeFieldsDef[fieldName]->getType();
                    let newFieldType =  newTypeFieldsDef[fieldName]->getType();
                    let isSafe =  self::isChangeSafeForInputObjectFieldOrFieldArg(oldFieldType, newFieldType);
                    if !(isSafe) {
                        let oldFieldTypeString =  oldFieldType instanceof NamedType ? oldFieldType->name  : oldFieldType;
                        let newFieldTypeString =  newFieldType instanceof NamedType ? newFieldType->name  : newFieldType;
                        let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_FIELD_CHANGED_KIND, "description" : "{typeName}.{fieldName} changed type from {oldFieldTypeString} to {newFieldTypeString}."];
                    }
                }
            }
            // Check if a field was added to the input object type
            for fieldName, fieldDef in newTypeFieldsDef {
                if !(isset oldTypeFieldsDef[fieldName]) {
                    let newTypeName =  newType->name;
                    if fieldDef->getType() instanceof NonNull {
                        let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_NON_NULL_INPUT_FIELD_ADDED, "description" : "A non-null field {fieldName} on input type {newTypeName} was added."];
                    } else {
                        let dangerousChanges[] =  ["type" : self::DANGEROUS_CHANGE_NULLABLE_INPUT_FIELD_ADDED, "description" : "A nullable field {fieldName} on input type {newTypeName} was added."];
                    }
                }
            }
        }
        let tmpArrayd73a0b4397d6ef8e78a102cf357061fc = ["breakingChanges" : breakingChanges, "dangerousChanges" : dangerousChanges];
        return tmpArrayd73a0b4397d6ef8e78a102cf357061fc;
    }
    
    protected static function isChangeSafeForObjectOrInterfaceField(<Type> oldType, <Type> newType)
    {
        if oldType instanceof NamedType {
            return newType instanceof NamedType && oldType->name === newType->name || newType instanceof NonNull && self::isChangeSafeForObjectOrInterfaceField(oldType, newType->getWrappedType());
        } elseif oldType instanceof ListOfType {
            return newType instanceof ListOfType && self::isChangeSafeForObjectOrInterfaceField(oldType->getWrappedType(), newType->getWrappedType()) || newType instanceof NonNull && self::isChangeSafeForObjectOrInterfaceField(oldType, newType->getWrappedType());
        } elseif oldType instanceof NonNull {
            // if they're both non-null, make sure the underlying types are compatible
            return newType instanceof NonNull && self::isChangeSafeForObjectOrInterfaceField(oldType->getWrappedType(), newType->getWrappedType());
        }
        return false;
    }
    
    /**
     * @param Type $oldType
     * @param Type $newType
     *
     * @return bool
     */
    protected static function isChangeSafeForInputObjectFieldOrFieldArg(<Type> oldType, <Type> newType) -> bool
    {
        if oldType instanceof NamedType {
            // if they're both named types, see if their names are equivalent
            return newType instanceof NamedType && oldType->name === newType->name;
        } elseif oldType instanceof ListOfType {
            // if they're both lists, make sure the underlying types are compatible
            return newType instanceof ListOfType && self::isChangeSafeForInputObjectFieldOrFieldArg(oldType->getWrappedType(), newType->getWrappedType());
        } elseif oldType instanceof NonNull {
            return newType instanceof NonNull && self::isChangeSafeForInputObjectFieldOrFieldArg(oldType->getWrappedType(), newType->getWrappedType()) || !(newType instanceof NonNull) && self::isChangeSafeForInputObjectFieldOrFieldArg(oldType->getWrappedType(), newType);
        }
        return false;
    }
    
    /**
     * Given two schemas, returns an Array containing descriptions of any breaking
     * changes in the newSchema related to removing types from a union type.
     *
     * @return array
     */
    public static function findTypesRemovedFromUnions(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, typesRemovedFromUnion, typeName, oldType, newType, typeNamesInNewUnion, type;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let typesRemovedFromUnion =  [];
        for typeName, oldType in oldTypeMap {
            let newType =  isset newTypeMap[typeName] ? newTypeMap[typeName]  : null;
            if !(oldType instanceof UnionType) || !(newType instanceof UnionType) {
                continue;
            }
            let typeNamesInNewUnion =  [];
            for type in newType->getTypes() {
                let typeNamesInNewUnion[type->name] = true;
            }
            for type in oldType->getTypes() {
                if !(isset typeNamesInNewUnion[type->name]) {
                    let typesRemovedFromUnion[] =  ["type" : self::BREAKING_CHANGE_TYPE_REMOVED_FROM_UNION, "description" : "{type->name} was removed from union type {typeName}."];
                }
            }
        }
        return typesRemovedFromUnion;
    }
    
    /**
     * Given two schemas, returns an Array containing descriptions of any dangerous
     * changes in the newSchema related to adding types to a union type.
     *
     * @return array
     */
    public static function findTypesAddedToUnions(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, typesAddedToUnion, typeName, newType, oldType, typeNamesInOldUnion, type;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let typesAddedToUnion =  [];
        for typeName, newType in newTypeMap {
            let oldType =  isset oldTypeMap[typeName] ? oldTypeMap[typeName]  : null;
            if !(oldType instanceof UnionType) || !(newType instanceof UnionType) {
                continue;
            }
            let typeNamesInOldUnion =  [];
            for type in oldType->getTypes() {
                let typeNamesInOldUnion[type->name] = true;
            }
            for type in newType->getTypes() {
                if !(isset typeNamesInOldUnion[type->name]) {
                    let typesAddedToUnion[] =  ["type" : self::DANGEROUS_CHANGE_TYPE_ADDED_TO_UNION, "description" : "{type->name} was added to union type {typeName}."];
                }
            }
        }
        return typesAddedToUnion;
    }
    
    /**
     * Given two schemas, returns an Array containing descriptions of any breaking
     * changes in the newSchema related to removing values from an enum type.
     *
     * @return array
     */
    public static function findValuesRemovedFromEnums(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, valuesRemovedFromEnums, typeName, oldType, newType, valuesInNewEnum, value;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let valuesRemovedFromEnums =  [];
        for typeName, oldType in oldTypeMap {
            let newType =  isset newTypeMap[typeName] ? newTypeMap[typeName]  : null;
            if !(oldType instanceof EnumType) || !(newType instanceof EnumType) {
                continue;
            }
            let valuesInNewEnum =  [];
            for value in newType->getValues() {
                let valuesInNewEnum[value->name] = true;
            }
            for value in oldType->getValues() {
                if !(isset valuesInNewEnum[value->name]) {
                    let valuesRemovedFromEnums[] =  ["type" : self::BREAKING_CHANGE_VALUE_REMOVED_FROM_ENUM, "description" : "{value->name} was removed from enum type {typeName}."];
                }
            }
        }
        return valuesRemovedFromEnums;
    }
    
    /**
     * Given two schemas, returns an Array containing descriptions of any dangerous
     * changes in the newSchema related to adding values to an enum type.
     *
     * @return array
     */
    public static function findValuesAddedToEnums(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, valuesAddedToEnums, typeName, oldType, newType, valuesInOldEnum, value;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let valuesAddedToEnums =  [];
        for typeName, oldType in oldTypeMap {
            let newType =  isset newTypeMap[typeName] ? newTypeMap[typeName]  : null;
            if !(oldType instanceof EnumType) || !(newType instanceof EnumType) {
                continue;
            }
            let valuesInOldEnum =  [];
            for value in oldType->getValues() {
                let valuesInOldEnum[value->name] = true;
            }
            for value in newType->getValues() {
                if !(isset valuesInOldEnum[value->name]) {
                    let valuesAddedToEnums[] =  ["type" : self::DANGEROUS_CHANGE_VALUE_ADDED_TO_ENUM, "description" : "{value->name} was added to enum type {typeName}."];
                }
            }
        }
        return valuesAddedToEnums;
    }
    
    /**
     * @param Schema $oldSchema
     * @param Schema $newSchema
     *
     * @return array
     */
    public static function findInterfacesRemovedFromObjectTypes(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, breakingChanges, typeName, oldType, newType, oldInterfaces, newInterfaces, oldInterface;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let breakingChanges =  [];
        for typeName, oldType in oldTypeMap {
            let newType =  isset newTypeMap[typeName] ? newTypeMap[typeName]  : null;
            if !(oldType instanceof ObjectType) || !(newType instanceof ObjectType) {
                continue;
            }
            let oldInterfaces =  oldType->getInterfaces();
            let newInterfaces =  newType->getInterfaces();
            for oldInterface in oldInterfaces {
                if !(Utils::find(newInterfaces, new FindBreakingChangesfindInterfacesRemovedFromObjectTypesClosureOne(oldInterface))) {
                    let breakingChanges[] =  ["type" : self::BREAKING_CHANGE_INTERFACE_REMOVED_FROM_OBJECT, "description" : "{typeName} no longer implements interface {oldInterface->name}."];
                }
            }
        }
        return breakingChanges;
    }
    
    /**
     * @param Schema $oldSchema
     * @param Schema $newSchema
     *
     * @return array
     */
    public static function findInterfacesAddedToObjectTypes(<Schema> oldSchema, <Schema> newSchema) -> array
    {
        var oldTypeMap, newTypeMap, interfacesAddedToObjectTypes, typeName, newType, oldType, oldInterfaces, newInterfaces, newInterface;
    
        let oldTypeMap =  oldSchema->getTypeMap();
        let newTypeMap =  newSchema->getTypeMap();
        let interfacesAddedToObjectTypes =  [];
        for typeName, newType in newTypeMap {
            let oldType =  isset oldTypeMap[typeName] ? oldTypeMap[typeName]  : null;
            if !(oldType instanceof ObjectType) || !(newType instanceof ObjectType) {
                continue;
            }
            let oldInterfaces =  oldType->getInterfaces();
            let newInterfaces =  newType->getInterfaces();
            for newInterface in newInterfaces {
                if !(Utils::find(oldInterfaces, new FindBreakingChangesfindInterfacesAddedToObjectTypesClosureOne(newInterface))) {
                    let interfacesAddedToObjectTypes[] =  ["type" : self::DANGEROUS_CHANGE_INTERFACE_ADDED_TO_OBJECT, "description" : "{newInterface->name} added to interfaces implemented by {typeName}."];
                }
            }
        }
        return interfacesAddedToObjectTypes;
    }
    
    public static function findRemovedDirectives(<Schema> oldSchema, <Schema> newSchema)
    {
        var removedDirectives, newSchemaDirectiveMap, directive;
    
        let removedDirectives =  [];
        let newSchemaDirectiveMap =  self::getDirectiveMapForSchema(newSchema);
        for directive in oldSchema->getDirectives() {
            if !(isset newSchemaDirectiveMap[directive->name]) {
                let removedDirectives[] =  ["type" : self::BREAKING_CHANGE_DIRECTIVE_REMOVED, "description" : "{directive->name} was removed"];
            }
        }
        return removedDirectives;
    }
    
    public static function findRemovedArgsForDirectives(<Directive> oldDirective, <Directive> newDirective)
    {
        var removedArgs, newArgMap, arg;
    
        let removedArgs =  [];
        let newArgMap =  self::getArgumentMapForDirective(newDirective);
        for arg in (array) oldDirective->args {
            if !(isset newArgMap[arg->name]) {
                let removedArgs[] = arg;
            }
        }
        return removedArgs;
    }
    
    public static function findRemovedDirectiveArgs(<Schema> oldSchema, <Schema> newSchema)
    {
        var removedDirectiveArgs, oldSchemaDirectiveMap, newDirective, arg;
    
        let removedDirectiveArgs =  [];
        let oldSchemaDirectiveMap =  self::getDirectiveMapForSchema(oldSchema);
        for newDirective in newSchema->getDirectives() {
            if !(isset oldSchemaDirectiveMap[newDirective->name]) {
                continue;
            }
            for arg in self::findRemovedArgsForDirectives(oldSchemaDirectiveMap[newDirective->name], newDirective) {
                let removedDirectiveArgs[] =  ["type" : self::BREAKING_CHANGE_DIRECTIVE_ARG_REMOVED, "description" : "{arg->name} was removed from {newDirective->name}"];
            }
        }
        return removedDirectiveArgs;
    }
    
    public static function findAddedArgsForDirective(<Directive> oldDirective, <Directive> newDirective)
    {
        var addedArgs, oldArgMap, arg;
    
        let addedArgs =  [];
        let oldArgMap =  self::getArgumentMapForDirective(oldDirective);
        for arg in (array) newDirective->args {
            if !(isset oldArgMap[arg->name]) {
                let addedArgs[] = arg;
            }
        }
        return addedArgs;
    }
    
    public static function findAddedNonNullDirectiveArgs(<Schema> oldSchema, <Schema> newSchema)
    {
        var addedNonNullableArgs, oldSchemaDirectiveMap, newDirective, arg;
    
        let addedNonNullableArgs =  [];
        let oldSchemaDirectiveMap =  self::getDirectiveMapForSchema(oldSchema);
        for newDirective in newSchema->getDirectives() {
            if !(isset oldSchemaDirectiveMap[newDirective->name]) {
                continue;
            }
            for arg in self::findAddedArgsForDirective(oldSchemaDirectiveMap[newDirective->name], newDirective) {
                if !(arg->getType() instanceof NonNull) {
                    continue;
                }
                let addedNonNullableArgs[] =  ["type" : self::BREAKING_CHANGE_NON_NULL_DIRECTIVE_ARG_ADDED, "description" : "A non-null arg {arg->name} on directive {newDirective->name} was added"];
            }
        }
        return addedNonNullableArgs;
    }
    
    public static function findRemovedLocationsForDirective(<Directive> oldDirective, <Directive> newDirective)
    {
        var removedLocations, newLocationSet, oldLocation;
    
        let removedLocations =  [];
        let newLocationSet =  array_flip(newDirective->locations);
        for oldLocation in oldDirective->locations {
            if !(array_key_exists(oldLocation, newLocationSet)) {
                let removedLocations[] = oldLocation;
            }
        }
        return removedLocations;
    }
    
    public static function findRemovedDirectiveLocations(<Schema> oldSchema, <Schema> newSchema)
    {
        var removedLocations, oldSchemaDirectiveMap, newDirective, location;
    
        let removedLocations =  [];
        let oldSchemaDirectiveMap =  self::getDirectiveMapForSchema(oldSchema);
        for newDirective in newSchema->getDirectives() {
            if !(isset oldSchemaDirectiveMap[newDirective->name]) {
                continue;
            }
            for location in self::findRemovedLocationsForDirective(oldSchemaDirectiveMap[newDirective->name], newDirective) {
                let removedLocations[] =  ["type" : self::BREAKING_CHANGE_DIRECTIVE_LOCATION_REMOVED, "description" : "{location} was removed from {newDirective->name}"];
            }
        }
        return removedLocations;
    }
    
    protected static function getDirectiveMapForSchema(<Schema> schema)
    {
        return Utils::keyMap(schema->getDirectives(), new FindBreakingChangesgetDirectiveMapForSchemaClosureOne());
    }
    
    protected static function getArgumentMapForDirective(<Directive> directive)
    {
        let tmpArray40cd750bba9870f18aada2478b24840a = [];
        return Utils::keyMap( directive->args ? directive->args : tmpArray40cd750bba9870f18aada2478b24840a, new FindBreakingChangesgetArgumentMapForDirectiveClosureOne());
    }

}