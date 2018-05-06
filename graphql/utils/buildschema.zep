namespace GraphQL\Utils;

use GraphQL\Error\Error;
use GraphQL\Language\AST\DocumentNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Language\AST\SchemaDefinitionNode;
use GraphQL\Language\Parser;
use GraphQL\Language\Source;
use GraphQL\Type\Schema;
use GraphQL\Type\Definition\Directive;
/**
 * Build instance of `GraphQL\Type\Schema` out of type language definition (string or parsed AST)
 * See [section in docs](type-system/type-language.md) for details.
 */
class BuildSchema
{
    /**
     * This takes the ast of a schema document produced by the parse function in
     * GraphQL\Language\Parser.
     *
     * If no schema definition is provided, then it will look for types named Query
     * and Mutation.
     *
     * Given that AST it constructs a GraphQL\Type\Schema. The resulting schema
     * has no resolve methods, so execution will use default resolvers.
     *
     * Accepts options as a third argument:
     *
     *    - commentDescriptions:
     *        Provide true to use preceding comments as the description.
     *
     *
     * @api
     * @param DocumentNode $ast
     * @param callable $typeConfigDecorator
     * @param array $options
     * @return Schema
     * @throws Error
     */
    public static function buildAST(<DocumentNode> ast, typeConfigDecorator = null, array options = []) -> <Schema>
    {
        var builder;
    
        let builder =  new self(ast, typeConfigDecorator, options);
        return builder->buildSchema();
    }
    
    protected ast;
    protected nodeMap;
    protected typeConfigDecorator;
    protected options;
    public function __construct(<DocumentNode> ast, typeConfigDecorator = null, array options = []) -> void
    {
        let this->ast = ast;
        let this->typeConfigDecorator = typeConfigDecorator;
        let this->options = options;
    }
    
    public function buildSchema()
    {
        var schemaDef, typeDefs, directiveDefs, d, typeName, operationTypes, defintionBuilder, directives, skip, include, deprecatedd, schema, tmpArray038810003600225bb4683b4f4bc6f743, types, name, def;
    
        /** @var SchemaDefinitionNode $schemaDef */
        let schemaDef =  null;
        let typeDefs =  [];
        let this->nodeMap =  [];
        let directiveDefs =  [];
        for d in this->ast->definitions {
            if NodeKind::SCHEMA_DEFINITION {
                if schemaDef {
                    throw new Error("Must provide only one schema definition.");
                }
                let schemaDef = d;
            } elseif NodeKind::SCALAR_TYPE_DEFINITION || NodeKind::OBJECT_TYPE_DEFINITION || NodeKind::INTERFACE_TYPE_DEFINITION || NodeKind::ENUM_TYPE_DEFINITION || NodeKind::UNION_TYPE_DEFINITION || NodeKind::INPUT_OBJECT_TYPE_DEFINITION {
                let typeName =  d->name->value;
                if !(empty(this->nodeMap[typeName])) {
                    throw new Error("Type \"{typeName}\" was defined more than once.");
                }
                let typeDefs[] = d;
                let this->nodeMap[typeName] = d;
            } else {
                let directiveDefs[] = d;
            }
        }
        let operationTypes =  schemaDef ? this->getOperationTypes(schemaDef)  : ["query" :  isset this->nodeMap["Query"] ? "Query"  : null, "mutation" :  isset this->nodeMap["Mutation"] ? "Mutation"  : null, "subscription" :  isset this->nodeMap["Subscription"] ? "Subscription"  : null];
        let defintionBuilder =  new ASTDefinitionBuilder(this->nodeMap, this->options, new BuildSchemabuildSchemaClosureOne(), this->typeConfigDecorator);
        let directives =  array_map(new BuildSchemabuildSchemaClosureOne(defintionBuilder), directiveDefs);
        // If specified directives were not explicitly declared, add them.
        let skip =  array_reduce(directives, new BuildSchemabuildSchemaClosureOne());
        if !(skip) {
            let directives[] = Directive::skipDirective();
        }
        let include =  array_reduce(directives, new BuildSchemabuildSchemaClosureOne());
        if !(include) {
            let directives[] = Directive::includeDirective();
        }
        let deprecatedd =  array_reduce(directives, new BuildSchemabuildSchemaClosureOne());
        if !(deprecatedd) {
            let directives[] = Directive::deprecatedDirective();
        }
        // Note: While this could make early assertions to get the correctly
        // typed values below, that would throw immediately while type system
        // validation with validateSchema() will produce more actionable results.
        let schema =  new Schema(let types =  [];
        let types[] =  defintionBuilder->buildType(def->name->value);
        ["query" :  isset operationTypes["query"] ? defintionBuilder->buildType(operationTypes["query"])  : null, "mutation" :  isset operationTypes["mutation"] ? defintionBuilder->buildType(operationTypes["mutation"])  : null, "subscription" :  isset operationTypes["subscription"] ? defintionBuilder->buildType(operationTypes["subscription"])  : null, "typeLoader" : new BuildSchemabuildSchemaClosureOne(defintionBuilder), "directives" : directives, "astNode" : schemaDef, "types" : new BuildSchemabuildSchemaClosureOne(defintionBuilder)]);
        return schema;
    }
    
    /**
     * @param SchemaDefinitionNode $schemaDef
     * @return array
     * @throws Error
     */
    protected function getOperationTypes(<SchemaDefinitionNode> schemaDef) -> array
    {
        var opTypes, operationType, typeName, operation;
    
        let opTypes =  [];
        for operationType in schemaDef->operationTypes {
            let typeName =  operationType->type->name->value;
            let operation =  operationType->operation;
            if isset opTypes[operation] {
                throw new Error("Must provide only one {operation} type in schema.");
            }
            if !(isset this->nodeMap[typeName]) {
                throw new Error("Specified {operation} type \"{typeName}\" not found in document.");
            }
            let opTypes[operation] = typeName;
        }
        return opTypes;
    }
    
    /**
     * A helper function to build a GraphQLSchema directly from a source
     * document.
     *
     * @api
     * @param DocumentNode|Source|string $source
     * @param callable $typeConfigDecorator
     * @param array $options
     * @return Schema
     */
    public static function build(source, typeConfigDecorator = null, array options = []) -> <Schema>
    {
        var doc;
    
        let doc =  source instanceof DocumentNode ? source  : Parser::parse(source);
        return self::buildAST(doc, typeConfigDecorator, options);
    }

}