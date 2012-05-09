var User = require("../cloud9.core/user");

module.exports = function startup(options, imports, register) {

    var connect = imports.connect;
    connect.useSession(function (req, res, next) {
        if (!req.session.uid) {
            req.session.uid = req.sessionID;
        }
        
        next();
    });

    register(null, {
        "workspace-permissions": {
            getPermissions: function(uid, workspaceId, callback) {
                if (!uid)
                    return callback(new Error("Invalid user id: " + uid));

                return callback(null, User.OWNER_PERMISSIONS);
            }
        }
    });
};