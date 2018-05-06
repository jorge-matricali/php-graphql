namespace GraphQL\Utils;

use GraphQL\Error\Error;
use GraphQL\Language\Printer;
use GraphQL\Type\Introspection;
use GraphQL\Type\Schema;
use GraphQL\Type\Definition\EnumType;
use GraphQL\Type\Definition\InputObjectType;
use GraphQL\Type\Definition\InterfaceType;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\ScalarType;
use GraphQL\Type\Definition\Type;
use GraphQL\Type\Definition\UnionType;
use GraphQL\Type\Definition\Directive;
/**
 * Given an instance of Schema, prints it in GraphQL type language.
 */
class SchemaPrinter
{
    /**
     * Accepts options as a second argument:
     *
     *    - commentDescriptions:
     *        Provide true to use preceding comments as the description.
     * @api
     * @param Schema $schema
     * @return string
     */
    public static function doPrint(<Schema> schema, array options = []) -> string
    {
        return self::printFilteredSchema(schema, new SchemaPrinterdoPrintClosureOne(), new SchemaPrinterdoPrintClosureOne(), options);
    }
    
    /**
     * @api
     * @param Schema $schema
     * @return string
     */
    public static function printIntrosepctionSchema(<Schema> schema, array options = []) -> string
    {
        var tmpArray417b65f8cee92e7369263951f0b92407, tmpArray2e8e2f5c268dc8e02f5ed5ba5bad2ab0;
    
        let tmpArray417b65f8cee92e7369263951f0b92407 = [Directive::class, "isSpecifiedDirective"];
        let tmpArray2e8e2f5c268dc8e02f5ed5ba5bad2ab0 = [Introspection::class, "isIntrospectionType"];
        return self::printFilteredSchema(schema, tmpArray417b65f8cee92e7369263951f0b92407, tmpArray2e8e2f5c268dc8e02f5ed5ba5bad2ab0, options);
    }
    
    protected static function printFilteredSchema(<Schema> schema, directiveFilter, typeFilter, options)
    {
        var directives, types, tmpArray1cd754416e6544cadb2be976fb641427;
    
        let directives =  array_filter(schema->getDirectives(), new SchemaPrinterprintFilteredSchemaClosureOne(directiveFilter));
        let types =  schema->getTypeMap();
        ksort(types);
        let types =  array_filter(types, typeFilter);
        let tmpArray1cd754416e6544cadb2be976fb641427 = [self::printSchemaDefinition(schema)];
        return implode("

", array_filter(array_merge(tmpArray1cd754416e6544cadb2be976fb641427, array_map(new SchemaPrinterprintFilteredSchemaClosureOne(options), directives), array_map(new SchemaPrinterprintFilteredSchemaClosureOne(options), types)))) . "
";
    }
    
    protected static function printSchemaDefinition(<Schema> schema)
    {
        var operationTypes, queryType, mutationType, subscriptionType;
    
        if self::isSchemaOfCommonNames(schema) {
            return;
        }
        let operationTypes =  [];
        let queryType =  schema->getQueryType();
        if queryType {
            let operationTypes[] = "  query: {queryType->name}";
        }
        let mutationType =  schema->getMutationType();
        if mutationType {
            let operationTypes[] = "  mutation: {mutationType->name}";
        }
        let subscriptionType =  schema->getSubscriptionType();
        if subscriptionType {
            let operationTypes[] = "  subscription: {subscriptionType->name}";
        }
        return "schema {
" . implode("
", operationTypes) . "
}";
    }
    
    /**
     * GraphQL schema define root types for each type of operation. These types are
     * the same as any other type and can be named in any manner, however there is
     * a common naming convention:
     *
     *   schema {
     *     query: Query
     *     mutation: Mutation
     *   }
     *
     * When using this naming convention, the schema description can be omitted.
     */
    protected static function isSchemaOfCommonNames(<Schema> schema)
    {
        var queryType, mutationType, subscriptionType;
    
        let queryType =  schema->getQueryType();
        if queryType && queryType->name !== "Query" {
            return false;
        }
        let mutationType =  schema->getMutationType();
        if mutationType && mutationType->name !== "Mutation" {
            return false;
        }
        let subscriptionType =  schema->getSubscriptionType();
        if subscriptionType && subscriptionType->name !== "Subscription" {
            return false;
        }
        return true;
    }
    
    public static function printType(<Type> type, array options = [])
    {
        if type instanceof ScalarType {
            return self::printScalar(type, options);
        } else {
            if type instanceof ObjectType {
                return self::printObject(type, options);
            } else {
                if type instanceof InterfaceType {
                    return self::printInterface(type, options);
                } else {
                    if type instanceof UnionType {
                        return self::printUnion(type, options);
                    } else {
                        if type instanceof EnumType {
                            return self::printEnum(type, options);
                        } else {
                            if type instanceof InputObjectType {
                                return self::printInputObject(type, options);
                            }
                        }
                    }
                }
            }
        }
        throw new Error("Unknown type: " . Utils::printSafe(type) . ".");
    }
    
    protected static function printScalar(<ScalarType> type, array options)
    {
        return self::printDescription(options, type) . "scalar {type->name}";
    }
    
    protected static function printObject(<ObjectType> type, array options)
    {
        var interfaces, implementedInterfaces;
    
        let interfaces =  type->getInterfaces();
        let implementedInterfaces =  !(empty(interfaces)) ? " implements " . implode(", ", array_map(new SchemaPrinterprintObjectClosureOne(), interfaces))  : "";
        return self::printDescription(options, type) . "type {type->name}{implementedInterfaces} {\n" . self::printFields(options, type) . "
" . "}";
    }
    
    protected static function printInterface(<InterfaceType> type, array options)
    {
        return self::printDescription(options, type) . "interface {type->name} {\n" . self::printFields(options, type) . "
" . "}";
    }
    
    protected static function printUnion(<UnionType> type, array options)
    {
        return self::printDescription(options, type) . "union {type->name} = " . implode(" | ", type->getTypes());
    }
    
    protected static function printEnum(<EnumType> type, array options)
    {
        return self::printDescription(options, type) . "enum {type->name} {\n" . self::printEnumValues(type->getValues(), options) . "
" . "}";
    }
    
    protected static function printEnumValues(values, options)
    {
        return implode("
", array_map(new SchemaPrinterprintEnumValuesClosureOne(options), values, array_keys(values)));
    }
    
    protected static function printInputObject(<InputObjectType> type, array options)
    {
        var fields;
    
        let fields =  array_values(type->getFields());
        return self::printDescription(options, type) . "input {type->name} {\n" . implode("
", array_map(new SchemaPrinterprintInputObjectClosureOne(options), fields, array_keys(fields))) . "
" . "}";
    }
    
    protected static function printFields(options, type)
    {
        var fields;
    
        let fields =  array_values(type->getFields());
        return implode("
", array_map(new SchemaPrinterprintFieldsClosureOne(options), fields, array_keys(fields)));
    }
    
    protected static function printArgs(options, args, indentation = "")
    {
        if !(args) {
            return "";
        }
        // If every arg does not have a description, print them on one line.
        if Utils::every(args, new SchemaPrinterprintArgsClosureOne()) {
            return "(" . implode(", ", array_map("self::printInputValue", args)) . ")";
        }
        return "(
" . implode("
", array_map(new SchemaPrinterprintArgsClosureOne(indentation, options), args, array_keys(args))) . "
" . indentation . ")";
    }
    
    protected static function printInputValue(arg)
    {
        var argDecl;
    
        let argDecl =  arg->name . ": " . (string) arg->getType();
        if arg->defaultValueExists() {
            let argDecl .= " = " . Printer::doPrint(ast::astFromValue(arg->defaultValue, arg->getType()));
        }
        return argDecl;
    }
    
    protected static function printDirective(directive, options)
    {
        return self::printDescription(options, directive) . "directive @" . directive->name . self::printArgs(options, directive->args) . " on " . implode(" | ", directive->locations);
    }
    
    protected static function printDeprecated(fieldOrEnumVal)
    {
        var reason;
    
        let reason =  fieldOrEnumVal->deprecationReason;
        if empty(reason) {
            return "";
        }
        if reason === "" || reason === Directive::DEFAULT_DEPRECATION_REASON {
            return " @deprecated";
        }
        return " @deprecated(reason: " . Printer::doPrint(ast::astFromValue(reason, Type::string())) . ")";
    }
    
    protected static function printDescription(options, def, indentation = "", firstInBlock = true)
    {
        var lines, description, line;
    
        if !(def->description) {
            return "";
        }
        let lines =  self::descriptionLines(def->description, 120 - strlen(indentation));
        if isset options["commentDescriptions"] {
            return self::printDescriptionWithComments(lines, indentation, firstInBlock);
        }
        let description =  indentation && !(firstInBlock) ? "
"  : "";
        if count(lines) === 1 && mb_strlen(lines[0]) < 70 {
            let description .= indentation . "\"\"\"" . self::escapeQuote(lines[0]) . "\"\"\"
";
            return description;
        }
        let description .= indentation . "\"\"\"
";
        for line in lines {
            let description .= indentation . self::escapeQuote(line) . "
";
        }
        let description .= indentation . "\"\"\"
";
        return description;
    }
    
    protected static function escapeQuote(line)
    {
        return str_replace("\"\"\"", "\\\"\"\"", line);
    }
    
    protected static function printDescriptionWithComments(lines, indentation, firstInBlock)
    {
        var description, line;
    
        let description =  indentation && !(firstInBlock) ? "
"  : "";
        for line in lines {
            if line === "" {
                let description .= indentation . "#
";
            } else {
                let description .= indentation . "# " . line . "
";
            }
        }
        return description;
    }
    
    protected static function descriptionLines(description, maxLen)
    {
        var lines, rawLines, line, sublines, subline;
    
        let lines =  [];
        let rawLines =  explode("
", description);
        for line in rawLines {
            if line === "" {
                let lines[] = line;
            } else {
                // For > 120 character long lines, cut at space boundaries into sublines
                // of ~80 chars.
                let sublines =  self::breakLine(line, maxLen);
                for subline in sublines {
                    let lines[] = subline;
                }
            }
        }
        return lines;
    }
    
    protected static function breakLine(line, maxLen)
    {
        var tmpArray73b129eed71c067bde6b45b4ca41b2e8, parts;
    
        if strlen(line) < maxLen + 5 {
            let tmpArray73b129eed71c067bde6b45b4ca41b2e8 = [line];
            return tmpArray73b129eed71c067bde6b45b4ca41b2e8;
        }
        preg_match_all("/((?: |^).{15," . (maxLen - 40) . "}(?= |$))/", line, parts);
        let parts = parts[0];
        return array_map(new SchemaPrinterbreakLineClosureOne(), parts);
    }

}