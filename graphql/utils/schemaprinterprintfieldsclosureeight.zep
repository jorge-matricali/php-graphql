namespace GraphQL\Utils;

class SchemaPrinterprintFieldsClosureEight
{
    private options;

    public function __construct(options)
    {
                let this->options = options;

    }

    public function __invoke(f, i)
    {
    return self::printDescription(this->options, f, "  ", !(i)) . "  " . f->name . self::printArgs(this->options, f->args, "  ") . ": " . (string) f->getType() . self::printDeprecated(f);
    }
}
    