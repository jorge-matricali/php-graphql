namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Language\AST\FieldNode;
use GraphQL\Language\AST\NodeKind;
use GraphQL\Validator\ValidationContext;
class DisableIntrospection extends AbstractQuerySecurity
{
    const ENABLED = 1;
    protected isEnabled;
    public function __construct(enabled = self::ENABLED) -> void
    {
        this->setEnabled(enabled);
    }
    
    public function setEnabled(enabled) -> void
    {
        let this->isEnabled = enabled;
    }
    
    static function introspectionDisabledMessage()
    {
        return "GraphQL introspection is not allowed, but the query contained __schema or __type";
    }
    
    protected function isEnabled()
    {
        return this->isEnabled !== static::DISABLED;
    }
    
    public function getVisitor(<ValidationContext> context)
    {
        var tmpArray74dc9cc6ac6e99f537abcf0b5dbec56d, tmpArrayb344384dac12a2cb87f0bdb2e4e82595;
    
        let tmpArray74dc9cc6ac6e99f537abcf0b5dbec56d = [NodeKind::FIELD : new DisableIntrospectiongetVisitorClosureOne(context)];
        return this->invokeIfNeeded(context, tmpArray1dc32428e7271469129716e74e189a9d);
    }

}