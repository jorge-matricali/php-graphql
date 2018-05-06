namespace GraphQL\Error;

/**
 * Encapsulates warnings produced by the library.
 *
 * Warnings can be suppressed (individually or all) if required.
 * Also it is possible to override warning handler (which is **trigger_error()** by default)
 */
final class Warning
{
    const WARNING_ASSIGN = 2;
    const WARNING_CONFIG = 4;
    const WARNING_FULL_SCHEMA_SCAN = 8;
    const WARNING_CONFIG_DEPRECATION = 16;
    const WARNING_NOT_A_TYPE = 32;
    const ALL = 63;
    static enableWarnings = self::ALL;
    static warned = [];
    protected static warningHandler;
    /**
     * Sets warning handler which can intercept all system warnings.
     * When not set, trigger_error() is used to notify about warnings.
     *
     * @api
     * @param callable|null $warningHandler
     */
    public static function setWarningHandler(warningHandler = null) -> void
    {
        let self::warningHandler = warningHandler;
    }
    
    /**
     * Suppress warning by id (has no effect when custom warning handler is set)
     *
     * Usage example:
     * Warning::suppress(Warning::WARNING_NOT_A_TYPE)
     *
     * When passing true - suppresses all warnings.
     *
     * @api
     * @param bool|int $suppress
     */
    static function suppress(suppress = true) -> void
    {
        if suppress === true {
            let self::enableWarnings = 0;
        } else {
            if suppress === false {
                let self::enableWarnings =  self::ALL;
            } else {
                let suppress =  (int) suppress;
                let self::enableWarnings = ~suppress;
            }
        }
    }
    
    /**
     * Re-enable previously suppressed warning by id
     *
     * Usage example:
     * Warning::suppress(Warning::WARNING_NOT_A_TYPE)
     *
     * When passing true - re-enables all warnings.
     *
     * @api
     * @param bool|int $enable
     */
    public static function enable(enable = true) -> void
    {
        if enable === true {
            let self::enableWarnings =  self::ALL;
        } else {
            if enable === false {
                let self::enableWarnings = 0;
            } else {
                let enable =  (int) enable;
                let self::enableWarnings = self::enableWarnings | enable;
            }
        }
    }
    
    static function warnOnce(errorMessage, warningId, messageLevel = null) -> void
    {
        var fn;
    
        if self::warningHandler {
            let fn =  self::warningHandler;
            {fn}(errorMessage, warningId);
        } else {
            if (self::enableWarnings & warningId) > 0 && !(isset self::warned[warningId]) {
                let self::warned[warningId] = true;
                trigger_error(errorMessage,  messageLevel ? messageLevel : E_USER_WARNING);
            }
        }
    }
    
    static function warn(errorMessage, warningId, messageLevel = null) -> void
    {
        var fn;
    
        if self::warningHandler {
            let fn =  self::warningHandler;
            {fn}(errorMessage, warningId);
        } else {
            if (self::enableWarnings & warningId) > 0 {
                trigger_error(errorMessage,  messageLevel ? messageLevel : E_USER_WARNING);
            }
        }
    }

}