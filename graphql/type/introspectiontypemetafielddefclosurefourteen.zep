namespace GraphQL\Type;

class IntrospectiontypeMetaFieldDefClosureFourteen
{

    public function __construct()
    {
        
    }

    public function __invoke(source, args, context, ResolveInfo info)
    {
    return info->schema->getType(args["name"]);
    }
}
    