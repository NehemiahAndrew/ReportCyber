const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const GitHubStrategy = require('passport-github2').Strategy;
const config = require('./config');
const User = require('../models/User');

const configurePassport = () => {
  // Serialize user for session
  passport.serializeUser((user, done) => {
    done(null, user.id);
  });

  // Deserialize user from session
  passport.deserializeUser(async (id, done) => {
    try {
      const user = await User.findById(id);
      done(null, user);
    } catch (error) {
      done(error, null);
    }
  });

  // Google OAuth Strategy
  if (config.oauth.google.clientId && config.oauth.google.clientSecret) {
    passport.use(
      new GoogleStrategy(
        {
          clientID: config.oauth.google.clientId,
          clientSecret: config.oauth.google.clientSecret,
          callbackURL: config.oauth.google.callbackUrl,
          scope: ['profile', 'email'],
        },
        async (accessToken, refreshToken, profile, done) => {
          try {
            // Check if user exists
            let user = await User.findOne({
              $or: [
                { 'oauth.google.id': profile.id },
                { email: profile.emails[0].value },
              ],
            });

            if (user) {
              // Update OAuth info if user exists
              if (!user.oauth.google.id) {
                user.oauth.google = {
                  id: profile.id,
                  email: profile.emails[0].value,
                };
                await user.save();
              }
              return done(null, user);
            }

            // Create new user
            user = await User.create({
              email: profile.emails[0].value,
              firstName: profile.name.givenName,
              lastName: profile.name.familyName,
              avatar: profile.photos[0]?.value,
              isEmailVerified: true,
              oauth: {
                google: {
                  id: profile.id,
                  email: profile.emails[0].value,
                },
              },
              role: 'user',
            });

            return done(null, user);
          } catch (error) {
            return done(error, null);
          }
        }
      )
    );
  }

  // GitHub OAuth Strategy
  if (config.oauth.github.clientId && config.oauth.github.clientSecret) {
    passport.use(
      new GitHubStrategy(
        {
          clientID: config.oauth.github.clientId,
          clientSecret: config.oauth.github.clientSecret,
          callbackURL: config.oauth.github.callbackUrl,
          scope: ['user:email'],
        },
        async (accessToken, refreshToken, profile, done) => {
          try {
            const email = profile.emails?.[0]?.value || `${profile.username}@github.local`;

            // Check if user exists
            let user = await User.findOne({
              $or: [
                { 'oauth.github.id': profile.id },
                { email: email },
              ],
            });

            if (user) {
              // Update OAuth info if user exists
              if (!user.oauth.github.id) {
                user.oauth.github = {
                  id: profile.id,
                  username: profile.username,
                };
                await user.save();
              }
              return done(null, user);
            }

            // Create new user
            user = await User.create({
              email: email,
              firstName: profile.displayName?.split(' ')[0] || profile.username,
              lastName: profile.displayName?.split(' ').slice(1).join(' ') || '',
              avatar: profile.photos[0]?.value,
              isEmailVerified: !!profile.emails?.[0]?.value,
              oauth: {
                github: {
                  id: profile.id,
                  username: profile.username,
                },
              },
              role: 'user',
            });

            return done(null, user);
          } catch (error) {
            return done(error, null);
          }
        }
      )
    );
  }

  return passport;
};

module.exports = configurePassport;
