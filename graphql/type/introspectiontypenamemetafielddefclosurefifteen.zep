namespace GraphQL\Type;

class IntrospectiontypeNameMetaFieldDefClosureFifteen
{

    public function __construct()
    {
        
    }

    public function __invoke(source, args, context, ResolveInfo info)
    {
    return info->parentType->name;
    }
}
    