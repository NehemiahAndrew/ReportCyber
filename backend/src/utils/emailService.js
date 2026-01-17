const nodemailer = require('nodemailer');
const config = require('../config/config');
const logger = require('./logger');

// Create transporter
const transporter = nodemailer.createTransport({
  host: config.email.smtp.host,
  port: config.email.smtp.port,
  secure: config.email.smtp.port === 465,
  auth: {
    user: config.email.smtp.auth.user,
    pass: config.email.smtp.auth.pass,
  },
});

/**
 * Send email
 * @param {Object} options - Email options
 */
const sendEmail = async (options) => {
  const mailOptions = {
    from: `"${config.email.fromName}" <${config.email.from}>`,
    to: options.to,
    subject: options.subject,
    html: options.html,
    text: options.text,
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    logger.info(`Email sent: ${info.messageId}`);
    return info;
  } catch (error) {
    logger.error('Email sending failed:', error);
    throw error;
  }
};

/**
 * Send verification email
 */
const sendVerificationEmail = async (email, name, verificationToken) => {
  const verificationUrl = `${config.frontendUrl}/verify-email?token=${verificationToken}`;
  
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; background: #667eea; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🛡️ ReportCyber</h1>
          <p>Crowdsourced Cyber Reporting Platform</p>
        </div>
        <div class="content">
          <h2>Welcome, ${name}!</h2>
          <p>Thank you for registering with ReportCyber. To complete your registration and start reporting cyber incidents, please verify your email address.</p>
          <p style="text-align: center;">
            <a href="${verificationUrl}" class="button">Verify Email Address</a>
          </p>
          <p>Or copy and paste this link in your browser:</p>
          <p style="word-break: break-all; color: #667eea;">${verificationUrl}</p>
          <p>This link will expire in 24 hours.</p>
          <p>If you didn't create an account with ReportCyber, please ignore this email.</p>
        </div>
        <div class="footer">
          <p>© ${new Date().getFullYear()} ReportCyber. All rights reserved.</p>
          <p>This is an automated message. Please do not reply.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  await sendEmail({
    to: email,
    subject: 'Verify Your ReportCyber Account',
    html,
    text: `Welcome to ReportCyber, ${name}! Please verify your email by visiting: ${verificationUrl}`,
  });
};

/**
 * Send password reset email
 */
const sendPasswordResetEmail = async (email, name, resetToken) => {
  const resetUrl = `${config.frontendUrl}/reset-password?token=${resetToken}`;
  
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .button { display: inline-block; background: #e74c3c; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .warning { background: #fff3cd; border: 1px solid #ffc107; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🛡️ ReportCyber</h1>
          <p>Password Reset Request</p>
        </div>
        <div class="content">
          <h2>Hello, ${name}</h2>
          <p>We received a request to reset your password for your ReportCyber account.</p>
          <p style="text-align: center;">
            <a href="${resetUrl}" class="button">Reset Password</a>
          </p>
          <p>Or copy and paste this link in your browser:</p>
          <p style="word-break: break-all; color: #667eea;">${resetUrl}</p>
          <div class="warning">
            <strong>⚠️ Security Notice:</strong> This link will expire in 1 hour. If you didn't request a password reset, please ignore this email and your password will remain unchanged.
          </div>
        </div>
        <div class="footer">
          <p>© ${new Date().getFullYear()} ReportCyber. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  await sendEmail({
    to: email,
    subject: 'Reset Your ReportCyber Password',
    html,
    text: `Hello ${name}, Reset your password by visiting: ${resetUrl}. This link expires in 1 hour.`,
  });
};

/**
 * Send report confirmation email
 */
const sendReportConfirmationEmail = async (email, name, reportId, reportType) => {
  const trackingUrl = `${config.frontendUrl}/reports/track/${reportId}`;
  
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .report-id { background: #e9ecef; padding: 15px; border-radius: 5px; text-align: center; font-size: 18px; font-weight: bold; margin: 20px 0; }
        .button { display: inline-block; background: #28a745; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>✅ Report Submitted</h1>
          <p>Your cyber incident report has been received</p>
        </div>
        <div class="content">
          <h2>Thank you${name ? `, ${name}` : ''}!</h2>
          <p>Your ${reportType} report has been successfully submitted to ReportCyber. Our team will review it shortly.</p>
          <div class="report-id">
            Report ID: ${reportId}
          </div>
          <p>Keep this ID for your records. You can use it to track the status of your report.</p>
          <p style="text-align: center;">
            <a href="${trackingUrl}" class="button">Track Your Report</a>
          </p>
          <h3>What happens next?</h3>
          <ol>
            <li><strong>Review:</strong> Our analysts will review your report</li>
            <li><strong>Verification:</strong> We may contact you for additional information</li>
            <li><strong>Action:</strong> Verified reports are escalated to appropriate authorities</li>
            <li><strong>Resolution:</strong> You'll be notified when the case is resolved</li>
          </ol>
        </div>
        <div class="footer">
          <p>© ${new Date().getFullYear()} ReportCyber. All rights reserved.</p>
          <p>Thank you for helping make the internet safer!</p>
        </div>
      </div>
    </body>
    </html>
  `;

  await sendEmail({
    to: email,
    subject: `Report Received - ${reportId}`,
    html,
    text: `Your ${reportType} report (ID: ${reportId}) has been submitted. Track it at: ${trackingUrl}`,
  });
};

/**
 * Send report status update email
 */
const sendReportStatusUpdateEmail = async (email, name, reportId, oldStatus, newStatus) => {
  const trackingUrl = `${config.frontendUrl}/reports/track/${reportId}`;
  
  const statusColors = {
    'submitted': '#6c757d',
    'under_review': '#ffc107',
    'verified': '#28a745',
    'escalated': '#dc3545',
    'resolved': '#17a2b8',
    'closed': '#343a40',
  };

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .status-badge { display: inline-block; padding: 8px 16px; border-radius: 20px; color: white; font-weight: bold; text-transform: uppercase; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>📋 Report Status Update</h1>
        </div>
        <div class="content">
          <h2>Hello${name ? `, ${name}` : ''}!</h2>
          <p>The status of your report <strong>${reportId}</strong> has been updated.</p>
          <p style="text-align: center;">
            <span style="color: ${statusColors[oldStatus] || '#6c757d'}">${oldStatus.replace('_', ' ').toUpperCase()}</span>
            → 
            <span class="status-badge" style="background: ${statusColors[newStatus] || '#6c757d'}">${newStatus.replace('_', ' ').toUpperCase()}</span>
          </p>
          <p style="text-align: center;">
            <a href="${trackingUrl}" style="color: #667eea;">View Full Report Details</a>
          </p>
        </div>
        <div class="footer">
          <p>© ${new Date().getFullYear()} ReportCyber. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  await sendEmail({
    to: email,
    subject: `Report ${reportId} - Status Updated to ${newStatus.replace('_', ' ').toUpperCase()}`,
    html,
    text: `Your report ${reportId} status has changed from ${oldStatus} to ${newStatus}. View details at: ${trackingUrl}`,
  });
};

/**
 * Send 2FA enabled notification
 */
const send2FAEnabledEmail = async (email, name) => {
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
        .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🔐 2FA Enabled</h1>
        </div>
        <div class="content">
          <h2>Hello, ${name}!</h2>
          <p>Two-factor authentication has been successfully enabled on your ReportCyber account.</p>
          <p>Your account is now more secure. You'll need to enter a verification code from your authenticator app each time you sign in.</p>
          <p><strong>Important:</strong> Make sure to keep your backup codes in a safe place in case you lose access to your authenticator app.</p>
        </div>
        <div class="footer">
          <p>© ${new Date().getFullYear()} ReportCyber. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  await sendEmail({
    to: email,
    subject: 'Two-Factor Authentication Enabled - ReportCyber',
    html,
    text: `Hello ${name}, Two-factor authentication has been enabled on your ReportCyber account.`,
  });
};

module.exports = {
  sendEmail,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendReportConfirmationEmail,
  sendReportStatusUpdateEmail,
  send2FAEnabledEmail,
};
